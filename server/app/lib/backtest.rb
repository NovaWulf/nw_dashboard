class Backtest
    @assets
    @asset_weights
    @cursor=1
    @model_starttime
    @model_endtime
    @signal
    @in_sample_mean
    @multiplier
    @max_trade_size_eth
    @positions
    @prices
    @num_obs
    @num_ownable_assets
    @targets
    @orders
    @starttimes
    @model_id
    @resolution
    attr_accessor :signal,:in_sample_mean,:in_sample_sd, :cursor,:target_positions, :prices,:num_ownable_assets,
    :asset_weights,:positions,:assets,:targets,:model_endttime,:starttimes
    attr_reader :model_id,:resolution

    MULTIPLIER = 1.0
    MAX_TRADE_SIZE_ETH = 1000

    def run(model_id:)
        self.load_model(model_id: model_id)
        self.set_initial_positions
        while true
            self.target_positions
            self.generate_orders
            cursor+=1 #time moves forward after setting target positions, before actually updating positions
            if cursor==num_obs 
                break
            end
            self.execute_trades
            self.calculate_pnl
        end
    end

    private
    def load_model(model_id:)
        model_id = BacktestModel.oldest_first.last&.model_id
        puts "model_id: "+model_id.to_s
        model = CointegrationModel.where("uuid = '#{model_id}'").last
        resolution = model&.resolution
        model_starttime = model&.model_starttime
        model_endtime = model&.model_endtime
        in_sample_sd = model&.in_sample_sd
        in_sample_mean = model&.in_sample_mean
        weights = CointegrationModelWeight.where("uuid = '#{model_id}'")
        assets = weights.pluck(:asset_name)
        asset_weights = weights.pluck(:weight)
        assets.delete("det")
        num_ownable_assets = assets.length()
        modeled_signal = ModeledSignal.where("model_id = '#{model_id}'").oldest_first
        puts "modeled_signal count: " + modeled_signal.count.to_s
        signal = modeled_signal.pluck(:value)
        puts "signal : " +signal.to_s
        starttimes = modeled_signal.pluck(:starttime)
        signal_starttime = starttimes[0]
        signal_endtime = starttimes.last
        puts "signal start time: " + signal_starttime.to_s
        num_obs = signal.length()
        puts "num obs: " + @num_obs.to_s
        positions = Array.new(num_ownable_assets){Array.new(num_obs)}
        pnl = Array.new(num_obs)
        pnl[0] = 0
        transactions = Array.new(num_obs)
        prices = Array.new(num_ownable_assets){Array.new(num_obs)}
        for i in 0..(num_ownable_assets-1)
            prices[i] = Candle.where("pair = '#{assets[i]}' and starttime >= #{signal_starttime} and starttime <= #{signal_endtime}").oldest_first.pluck(:close)
        end
    end

    def target_positions
        target_positions = Array.new(num_ownable_assets)
        for i in 0..(num_ownable_assets-1)
            if signal_up(cursor)
                target_positions[i] = - asset_weights[i] * MAX_TRADE_SIZE_ETH
            elsif signal_down(cursor)
                target_positions[i] = asset_weights[i]*MAX_TRADE_SIZE_ETH
            else 
                target_positions[i] = positions[i][cursor]
            end
        end

        targets = target_positions
    end

    def generate_orders
        deltas = Array.new(num_ownable_assets)
        for i in 0..(num_ownable_assets-1)
            deltas[i] = targets[i] - positions[i][cursor]
        end
        orders = deltas
    end

    def execute_trades
        for i in 0..(num_ownable_assets-1)
            positions[i][cursor] = positions[i][cursor-1]+orders[i]
            orders[i]=0
        end
    end

    def calculate_pnl
      
        pnl[cursor] = 0
        for i in 0..(num_ownable_assets-1)
            pnl[cursor] += positions[i][cursor]*(prices[i][cursor]-prices[i][cursor-1])
            in_sample_flag = true
            if starttimes[cursor] > model_endtime
                in_sample_flag=false
            end
        end
        pnl[cursor] += pnl[cursor-1]
        r_count = ModeledSignal.where("model_id=#{model_id}-b and starttime=#{starttimes[cursor]}").r_count
        if r_count==0
            ModeledSignal.create(
                starttime: starttimes[cursor],
                model_id: model_id+"-b",
                resolution: resolution,
                value: pnl[cursor],
                in_sample:in_sample_flag
            )
        end
        
    end

    def set_initial_positions
        return unless cursor == 0
        for i in 0..(num_ownable_assets-1)
            positions[i][cursor] = 0
        end
    end

    def signal_up(index)
        returnVal = false
        if signal[index]>in_sample_mean + in_sample_sd*MULTIPLIER
            returnVal = true
        end
        return returnVal
    end

    def signal_down(index)
        returnVal = false
        if signal[index]<in_sample_mean - in_sample_sd*MULTIPLIER
            returnVal = true
        end
        return returnVal
    end
    
end
