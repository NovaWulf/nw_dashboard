class ArbitrageCalculator < BaseService
  def run
    most_recent_backtest_model = BacktestModel.oldest_first.last
    Rails.logger.info "most recent backtest model exists? #{BacktestModel.oldest_first.count}"
    most_recent_model_id = most_recent_backtest_model.model_id
    Rails.logger.info "most recent model id: #{most_recent_model_id}"
    Rails.logger.info "unique model ids in database: #{CointegrationModel.pluck(:uuid).uniq}"
    most_recent_model = CointegrationModel.where("uuid='#{most_recent_model_id}'").last
    last_in_sample_timestamp = most_recent_model.model_endtime
    op_weight = CointegrationModelWeight.where("uuid = '#{most_recent_model_id}' and asset_name = 'op-usd'").pluck(:weight)[0]
    eth_weight = CointegrationModelWeight.where("uuid = '#{most_recent_model_id}' and asset_name = 'eth-usd'").pluck(:weight)[0]
    const_weight = CointegrationModelWeight.where("uuid = '#{most_recent_model_id}' and asset_name = 'det'").pluck(:weight)[0]
    if !op_weight || !eth_weight || !const_weight
      Rails.logger.info "model weight is null or model does not exist, aborting"
      abort "model weight is null, aborting"
    end
    res = 60
    last_timestamp = ModeledSignal.by_model(most_recent_model_id).last&.starttime
    return if last_timestamp && last_timestamp > Time.now.to_i - res

    start_time = last_timestamp ? last_timestamp + res : Date.new(2022, 6, 13).to_time.to_i
    starttimes = Candle.by_resolution(res).where("starttime>= #{start_time}").pluck(:starttime)
    starttimes = starttimes.uniq.sort
    puts "length of start times in arb: " + starttimes.length().to_s
    eth_not_null = 0
    op_not_null = 0
    index = 0
    current_eth_val = nil
    current_op_val = nil
    # this code block cycles through the candles until we have a record from each of OP and ETHHey
    # so that we can start the forward-filling of missing timesteps using most recent values
    while true
      this_start_time = starttimes[index]
      this_op_candle = Candle.by_resolution(res).by_pair('op-usd').where("starttime = #{this_start_time}")
      this_eth_candle = Candle.by_resolution(res).by_pair('eth-usd').where("starttime = #{this_start_time}")

      if this_op_candle.count.positive?
        op_not_null = 1
        current_op_val = this_op_candle.pluck(:close)[0]
      end
      if this_eth_candle.count.positive?
        eth_not_null = 1
        current_eth_val = this_eth_candle.pluck(:close)[0]
      end
      break if eth_not_null == 1 && op_not_null == 1

      index += 1
    end
    length_start_times = starttimes.length
    starttimes = starttimes[index..(length_start_times - 1)]
    m = nil
    starttimes.each do |time|
      this_op_candle = Candle.by_resolution(res).by_pair("op-usd").where("starttime = #{time}")
      this_eth_candle = Candle.by_resolution(res).by_pair("eth-usd").where("starttime = #{time}")
      
      # update current candle value if not null, otherwise, use most recent non-null value 
      # and create a new candle using the old value for flat-forward interpolation
      # (useful for better efficiency during backtesting)
      
      if this_op_candle.count >0
          current_op_val = this_op_candle.pluck(:close)[0]
      else
        Candle.create(starttime: time, pair: "op-usd",exchange: "Coinbase",
          resolution:res,low:current_op_val,high: current_op_val,open:current_op_val,close: current_op_val,volume:0)
      end
      if this_eth_candle.count>0
          current_eth_val = this_eth_candle.pluck(:close)[0]
      else 
        Candle.create(starttime: time, pair: "eth-usd",exchange: "Coinbase",
          resolution:res,low:current_eth_val,high: current_eth_val,open:current_eth_val,close: current_eth_val,volume:0)
      end
      signal_value = current_op_val*op_weight + current_eth_val*eth_weight + const_weight
      in_sample_flag = time <= last_in_sample_timestamp
      m=ModeledSignal.create(starttime: time, model_id: most_recent_model_id, resolution: res, value: signal_value,in_sample:in_sample_flag)

    end

    email_notification(m) if m
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
