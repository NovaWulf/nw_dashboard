class ArbitrageCalculator < BaseService
    
    def run
      tracked_pairs = ["eth-usd","op-usd"]
      tracked_pairs.each do |p|
        Fetchers::CoinbaseFetcher.run(resolution: 60, pair: p)
      end
      mostRecentModelID = CointegrationModel.newest_first.first&.uuid

      opWeight = CointegrationModelWeight.where("uuid = '#{mostRecentModelID}' and asset_name = 'op-usd'").pluck(:weight)[0]
      ethWeight = CointegrationModelWeight.where("uuid = '#{mostRecentModelID}' and asset_name = 'eth-usd'").pluck(:weight)[0]
      constWeight = CointegrationModelWeight.where("uuid = '#{mostRecentModelID}' and asset_name = 'det'").pluck(:weight)[0]
      puts "OP weight: " + opWeight.to_s + " ETH_WEIGHT: " + ethWeight.to_s + " CONST_WEIGHT: " + constWeight.to_s
      res= 60
      last_timestamp = ModeledSignal.by_model(mostRecentModelID).last&.starttime
      
      start_time = last_timestamp ? last_timestamp + res : Date.new(2022, 6, 13).to_time.to_i
      puts "start time: " + start_time.to_s

      starttimes = Candle.by_resolution(res).where("starttime> #{start_time}").pluck(:starttime)
      puts "length of start times: " + starttimes.length().to_s
      starttimes = starttimes.uniq.sort
      puts "length of uniq start times: " + starttimes.length().to_s
    #   minOPTime = Candle.by_resolution(res).by_pair("op-usd").where("starttime> #{starttime}").minimum(:starttime)
    #   minETHTime = Candle.by_resolution(res).by_pair("eth-usd").where("starttime> #{starttime}").minimum(:starttime)
      
      ethNotNull=0
      opNotNull=0
      index = 0
      currentEthVal = nil
      currentOpVal = nil
      #this code block cycles through the candles until we have a record from each of OP and ETH
      #so that we can start the forward-filling of missing timesteps using most recent values
      while true
        thisStartTime = starttimes[index]
        thisOpCandle = Candle.by_resolution(res).by_pair("op-usd").where("starttime = #{thisStartTime}")
        thisEthCandle = Candle.by_resolution(res).by_pair("eth-usd").where("starttime = #{thisStartTime}")
        puts "eth candle: " + thisEthCandle.count.to_s
        puts "op candle: " + thisOpCandle.count.to_s
        if thisOpCandle.count >0
            opNotNull=1
            currentOpVal = thisOpCandle.pluck(:close)[0]
        end
        if thisEthCandle.count>0
            ethNotNull=1
            currentEthVal = thisEthCandle.pluck(:close)[0]
        end
        if ethNotNull and opNotNull
            break
        end
        index = index+1
      end
      puts "index: " + index.to_s 
      counter=0
      lengthStartTimes =starttimes.length()
      starttimes = starttimes[index..(lengthStartTimes-1)]
      m=nil
      starttimes.each do |time|
        thisOpCandle = Candle.by_resolution(res).by_pair("op-usd").where("starttime = #{time}")
        thisEthCandle = Candle.by_resolution(res).by_pair("eth-usd").where("starttime = #{time}")
        
        # update current candle value if not null, otherwise, use most recent non-null value (flat-forward interpolation)
        if thisOpCandle.count >0
            currentOpVal = thisOpCandle.pluck(:close)[0]
        end
        if thisEthCandle.count>0
            currentEthVal = thisEthCandle.pluck(:close)[0]
        end
        puts "currentOpVal: " + currentOpVal.to_s + " opWeight: " + opWeight.to_s + " currentEthVal: " + currentEthVal.to_s + " ethWeight: " + ethWeight.to_s + " constWeight: " + constWeight.to_s
        signalValue = currentOpVal*opWeight + currentEthVal*ethWeight + constWeight
        
        m=ModeledSignal.create(starttime: time, model_id: mostRecentModelID, resolution: res, value: signalValue)
      end

    email_notification(m) if m
    end
    
  
    def email_notification(arb_signal,sigma = 1)
      mostRecentModel =   CointegrationModel.newest_first.first
      in_sample_mean = mostRecentModel&.in_sample_mean
      in_sample_sd  = mostRecentModel&.in_sample_sd 
      return unless arb_signal && mostRecentModel
      puts "sending email!"
      signal_value = arb_signal.value
      upper = in_sample_mean + sigma*in_sample_sd
      lower = in_sample_mean - sigma*in_sample_sd
  
      if signal_value > upper 
        NotificationMailer.with(subject: 'Statistical Arbitrage Indicator Alert',
                                text: "OP-ETH spread value (#{signal_value.round(2)}) is above the high band of Paul's indicator (#{(upper).round(2)})").notification.deliver_now
      elsif signal_value < lower
        NotificationMailer.with(subject: 'Statistical Arbitrage Indicator Alert',
                                text: "OP-ETH (#{signal_value.round(2)}) is below the low band of Paul's indicator (#{(lower).round(2)})").notification.deliver_now
      end

    end
  end
  