class ArbitrageCalculator < BaseService
  attr_reader :version, :most_recent_model, :silent, :assets

  def initialize(version:, basket:, silent: false)
    @version = version
    @silent = silent
    @basket = basket
  end

  def run
    most_recent_backtest_model = BacktestModel.where("version = #{version} and basket=#{basket}").oldest_sequence_number_first.last
    Rails.logger.info "running arb calculator on sequence number #{most_recent_backtest_model&.sequence_number}"

    most_recent_model_id = most_recent_backtest_model&.model_id
    @most_recent_model = CointegrationModel.where("uuid='#{most_recent_model_id}'").last
    det_type = most_recent_model&.ecdet
    log_prices = most_recent_model&.log_prices
    res = most_recent_model&.resolution
    last_in_sample_timestamp = most_recent_model&.model_endtime
    first_in_sample_timestamp = most_recent_model&.model_starttime
    assets = CointegrationModelWeight.where("uuid = '#{most_recent_model_id}'").pluck(:weight, :asset_name)
    asset_weights = assets.map { |x| x[0] }
    asset_names = assets.map { |x| x[1] }
    det_index = asset_names.index('det')
    det_weight = asset_weights[det_index]
    asset_weights.delete_at(det_index)
    asset_names.delete('det')
    last_timestamp = ModeledSignal.by_model(most_recent_model_id).last&.starttime
    return if last_timestamp && last_timestamp > Time.now.to_i - res

    last_prices = [nil, nil]
    if last_timestamp
      last_prices = asset_names.map do |name|
        Candle.where("starttime<=#{last_timestamp} and pair = '#{name}'").oldest_first.last&.close
      end
    end

    first_timestamps = asset_names.map { |a| Candle.where("pair = '#{a}'").oldest_first.first&.starttime }
    start_time = last_timestamp ? last_timestamp + res : first_in_sample_timestamp
    flat_records = PriceMerger.run(asset_names, start_time).value
    starttimes = flat_records[0]
    prices = flat_records[1]
    interp_count = 0
    for time_step in 0..(starttimes.length - 1)
      signal_value = if det_type == 'const'
                       det_weight
                     elsif det_type == 'trend'
                       time_step * det_weight
                     else
                       0
                     end
      for i in 0..(asset_weights.length - 1)
        if prices[i][time_step].nil?
          prices[i][time_step] = last_prices[i]
          interp_count += 1
          Candle.create(starttime: starttimes[time_step], pair: asset_names[i], exchange: 'Coinbase', resolution: res,
                        low: last_prices[i], high: last_prices[i], open: last_prices[i], close: last_prices[i], volume: last_prices[i], interpolated: true)
        else
          last_prices[i] = prices[i][time_step]
        end

        signal_value += if log_prices
                          asset_weights[i] * Math.log(prices[i][time_step])
                        else
                          asset_weights[i] * prices[i][time_step]
                        end
      end
      in_sample_flag = starttimes[time_step] <= last_in_sample_timestamp
      m = ModeledSignal.create(starttime: starttimes[time_step], model_id: most_recent_model_id, resolution: res, value: signal_value,
                               in_sample: in_sample_flag)
    end
    Rails.logger.info "flat forward interpolated #{interp_count} values"

    email_notification(m) if !silent && m
  end

  def email_notification(arb_signal, sigma = 1)
    in_sample_mean = most_recent_model&.in_sample_mean
    in_sample_sd = most_recent_model&.in_sample_sd
    return unless arb_signal && most_recent_model

    signal_value = arb_signal.value
    upper = in_sample_mean + sigma * in_sample_sd
    lower = in_sample_mean - sigma * in_sample_sd
    if signal_value > upper
      NotificationMailer.with(subject: 'Statistical Arbitrage Indicator Alert',
                              text: "#{basket} spread value (#{signal_value.round(2)}) is above the high band of Paul's indicator (#{upper.round(2)}). Recommend buying OP and shorting ETH").notification.deliver_now
    elsif signal_value < lower
      NotificationMailer.with(subject: 'Statistical Arbitrage Indicator Alert',
                              text: "#{basket} (#{signal_value.round(2)}) is below the low band of Paul's indicator (#{lower.round(2)}). Recommend buying ETH and shorting OP").notification.deliver_now
    end
  end
end
