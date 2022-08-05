class ArbitrageCalculator < BaseService
  def run
    most_recent_backtest_model = BacktestModel.oldest_version_first.oldest_sequence_number_first.last
    most_recent_model_id = most_recent_backtest_model&.model_id
    most_recent_model = CointegrationModel.where("uuid='#{most_recent_model_id}'").last
    log_prices = most_recent_model&.log_prices
    res = most_recent_model&.resolution
    last_in_sample_timestamp = most_recent_model&.model_endtime
    first_in_sample_timestamp = most_recent_model&.model_starttime
    assets = CointegrationModelWeight.where("uuid = '#{most_recent_model_id}'")
    asset_weights = assets.pluck(:weight)
    asset_names = assets.pluck(:asset_name)
    det_index = asset_names.index('det')
    det_weight = asset_weights[det_index]
    asset_weights.delete_at(det_index)
    asset_names.delete('det')
    flat_records = PriceProcessor.run(asset_names, first_in_sample_timestamp)
    starttimes = flat_records[0]
    prices = flat_records[1]
    for time_step in 0..(starttimes.length - 1)
      signal_value = det_weight
      for i in 0..(asset_weights.length - 1)
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

    # email_notification(m) if m
  end

  def email_notification(arb_signal, sigma = 1)
    most_recent_model = CointegrationModel.newest_first.first
    in_sample_mean = most_recent_model&.in_sample_mean
    in_sample_sd = most_recent_model&.in_sample_sd
    return unless arb_signal && most_recent_model

    signal_value = arb_signal.value
    upper = in_sample_mean + sigma * in_sample_sd
    lower = in_sample_mean - sigma * in_sample_sd
    if signal_value > upper
      NotificationMailer.with(subject: 'Statistical Arbitrage Indicator Alert',
                              text: "OP-ETH spread value (#{signal_value.round(2)}) is above the high band of Paul's indicator (#{upper.round(2)}). Recommend buying OP and shorting ETH").notification.deliver_now
    elsif signal_value < lower
      NotificationMailer.with(subject: 'Statistical Arbitrage Indicator Alert',
                              text: "OP-ETH (#{signal_value.round(2)}) is below the low band of Paul's indicator (#{lower.round(2)}). Recommend buying ETH and shorting OP").notification.deliver_now
    end
  end
end
