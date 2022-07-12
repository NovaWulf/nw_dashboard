class ArbitrageCalculator < BaseService
    
    ETH_WEIGHT = 1
    OP_WEIGHT = -2174.7378
    CONST_WEIGHT = 37.531326
    MODEL_ID = "adb21bd1-2204-ba24-07ac-36b78eb7dfc4"

    def run
    #   tracked_pairs = ["eth-usd","op-usd"]
    #   tracked_pairs.each do |p|
    #     Fetchers::CoinbaseFetcher.run(resolution: 60, pair: p)
    #   end
    mostRecentModelID = CointegrationModels.newest_first.first&.uuid
    puts "mostRecentModelID: " + mostRecentModelID.to_s
    #   res= 60
    #   last_timestamp = ModeledSignal.by_model(MODEL_ID).last&.starttime
      
    #   start_time = last_timestamp ? last_timestamp + res : Date.new(2022, 6, 13).to_time.to_i
    #   puts "start time: " + start_time.to_s

    #   starttimes = Candle.by_resolution(res).where("starttime> " + start_time.to_s).pluck(:starttime)
    #   puts "length of start times: " + starttimes.length().to_s
    #   starttimes = starttimes.uniq.sort
    #   puts "length of uniq start times: " + starttimes.length().to_s

    #   counter=0
    #   starttimes.each do |time|
    #     counter = counter+1
    #     if counter<10
    #         puts time.to_s
    #     end
    #   end
    #   opCandles = Candle.by_resolution(res).where("starttime > "+start_time.to_s).by_pair("op-usd")
    #   ethCandles = Candle.by_resolution(res).where("starttime > "+start_time.to_s).by_pair("eth-usd")
    


    #   puts "length of candles: " + ethCandles.length().to_s + " length of op candles: " + opCandles.length().to_s
    #   m = nil
    #   (start_date..Date.today).each do |day|
    #     s2f = Metric.by_token('btc').by_metric('s2f_ratio').by_day(day).first
    #     unless s2f&.value
    #       Rails.logger.error "can't generate Jesse metric, no s2f for #{day}"
    #       next
    #     end
  
    #     value = s2f.value * S2F_COEFF +
    #             hash_rate.value * HASHRATE_COEFF +
    #             google_trends.value * GOOGLE_TRENDS_COEFF +
    #             (active_addresses.value * active_addresses.value) * ACTIVE_ADDRESSES_COEFF +
    #             Y_INTERCEPT
  
    #     m = Metric.create(timestamp: day, value: value, token: 'btc', metric: 'jesse')
    #   end
  
    #  email_notification m if m
    end
    
  
    # def email_notification(jesse_metric)
    #   btc_price = Metric.by_token('btc').by_metric('price').by_day(jesse_metric.timestamp).first
  
    #   return unless btc_price && jesse_metric
  
    #   btc_value = btc_price.value
    #   jesse_value = jesse_metric.value
  
    #   if btc_value > jesse_value + STD_ERROR
    #     NotificationMailer.with(subject: 'Jesse Indicator Alert',
    #                             text: "BTC (#{btc_value.round(2)}) is above the high band of Jesse's indicator (#{(jesse_value + STD_ERROR).round(2)})").notification.deliver_now
    #   elsif btc_value < jesse_value - STD_ERROR
    #     NotificationMailer.with(subject: 'Jesse Indicator Alert',
    #                             text: "BTC (#{btc_value.round(2)}) is below the low band of Jesse's indicator (#{(jesse_value - STD_ERROR).round(2)})").notification.deliver_now
    #   end
    # end
  end
  