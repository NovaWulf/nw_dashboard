class Backtest
    @assets
    @ownable_assets
    @asset_weights
    @cursor
    @model_starttime
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
    def initialize 
        @cursor = 0
        @multiplier = 1.0
        @max_trade_size_eth = 1000
    end
    def load_model(model_id:)
        puts "loading model..."
        model = CointegrationModel.where("uuid = '#{model_id}'").last
        @model_starttime = model&.model_starttime
        @in_sample_sd = model&.in_sample_sd
        @in_sample_mean = model&.in_sample_mean
        puts "loading model weights..."
        weights = CointegrationModelWeight.where("uuid = '#{model_id}'")
        puts "number of weights for model: " + weights.count.to_s
        @assets = weights.pluck(:asset_name)
        @asset_weights = weights.pluck(:weight)
        puts "assets: " + @assets.to_s
        @ownable_assets = @assets.delete("det")
        @num_ownable_assets = @ownable_assets.length()
        
        puts "model starttime: " + @model_starttime.to_s
        puts "loading arbitrage signal..."
        modeled_signal = ModeledSignal.where("model_id = '#{model_id}'").oldest_first
        @signal = modeled_signal.pluck(:value)
        @starttimes = modeled_signal.pluck(:starttime)
        @num_obs = @signal.length()
        @positions = Array.new(@num_obs){Array.new(@num_ownable_assets)}
        @pnl = Array.new(@num_obs)
        @transactions = Array.new(@num_obs)
        puts "loading prices..."
        @prices = Array.new(@num_obs){Array.new(@num_ownable_assets)}
        for i in 0..(@num_obs-1)
            puts (100.0*i/(@num_obs-1)).to_s + "% done"
            this_start_time = @starttimes[i]
            for j in 0..(@num_ownable_assets)
                # this is a slow but simple way of getting the most recent asset price on each time step for the signal
                @prices[i][j] = Candle.where("pair = '#{@assets[j]}' and starttime = #{this_start_time}").last&.close
            end
        end
        puts "done loading"
    end
    def target_positions()
        target_positions = Array.new(@num_ownable_assets)
        for i in 0..@num_ownable_assets
            if signal_up(@cursor)
                target_positions[i] = - @asset_weights[i] * max_trade_size_eth
            end
            if signal_down(@cursor)
                target_positions[i] = @asset_weights[i]*max_trade_size_eth
            end
        end
        @targets = target_positions
    end
    def generate_orders()
        deltas = Array.new(@num_ownable_assets)
        for i in 0..@num_ownable_assets
            deltas[i] = @targets - positions[@cursor][i]
        end
        @orders = deltas
    end
    def execute_trades()
        for i in 0..num_ownable_assets
            @positions[@cursor][i] = positions[@cursor-1][i]+@orders[i]
            @orders[i]=0
        end
    end
    def calculate_pnl
        for i in 0..num_ownable_assets
            pnl[@cursor] = positions[@cursor][i]*(prices[@cursor][i]-prices[@cursor-1][i])
        end
    end
    def set_initial_positions()
        return unless @cursor == 0
        for i in 0..@num_ownable_assets
            positions[@cursor][i] = 0
        end
    end

    def signal_up(index)
        returnVal = false
        if signal[index]>@in_sample_mean + @in_sample_sd*@multiplier
            returnVal = true
        end
        return returnVal
    end
    def signal_down(index)
        returnVal = false
        if signal[index]<@in_sample_mean - @in_sample_sd*@multiplier
            returnVal = true
        end
        return returnVal
    end
    def run_simulation(model_id:)
        self.load_model(model_id: model_id)
        self.set_initial_positions
        while true
            self.target_positions
            self.generate_orders
            @cursor+=1 #time moves forward after setting target positions, before actually updating positions
            if @cursor==numObs 
                break
            end
            self.execute_trades
            self.calculate_pnl
        end
    end
end
