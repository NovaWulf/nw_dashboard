class Backtest
    @assets
    @asset_weights
    @cursor
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
    def initialize 
        @cursor = 0
        @multiplier = 1.0
        @max_trade_size_eth = 1000
    end
    def load_model(model_id:)
        @model_id = model_id
        puts "loading model..."
        model = CointegrationModel.where("uuid = '#{model_id}'").last
        @resolution = model&.resolution
        @model_starttime = model&.model_starttime
        @model_endtime = model&.model_endtime
        @in_sample_sd = model&.in_sample_sd
        @in_sample_mean = model&.in_sample_mean
        puts "loading model weights..."
        weights = CointegrationModelWeight.where("uuid = '#{model_id}'")
        puts "number of weights for model: " + weights.count.to_s
        @assets = weights.pluck(:asset_name)
        @asset_weights = weights.pluck(:weight)
        puts "assets: " + @assets.to_s
        @assets.delete("det")
        @num_ownable_assets = @assets.length()

        puts "@num_ownable_assets: "+@num_ownable_assets.to_s
        puts "loading arbitrage signal..."
        modeled_signal = ModeledSignal.where("model_id = '#{model_id}'").oldest_first
        @signal = modeled_signal.pluck(:value)
        @starttimes = modeled_signal.pluck(:starttime)
        puts "unique start times: " + @starttimes.uniq.length().to_s

        signal_starttime = @starttimes[0]
        signal_endtime = @starttimes[@starttimes.length()-1]
        @num_obs = @signal.length()
        @positions = Array.new(@num_ownable_assets){Array.new(@num_obs)}
        @pnl = Array.new(@num_obs)
        @transactions = Array.new(@num_obs)
        puts "loading prices..."
        @prices = Array.new(@num_ownable_assets){Array.new(@num_obs)}
        for i in 0..(@num_ownable_assets-1)
            @prices[i] = Candle.where("pair = '#{@assets[i]}' and starttime >= #{signal_starttime} and starttime <= #{signal_endtime}").oldest_first.pluck(:close)
        end
        puts "done loading"
    end
    def target_positions
        target_positions = Array.new(@num_ownable_assets)
        for i in 0..(@num_ownable_assets-1)
            if signal_up(@cursor)
                target_positions[i] = - @asset_weights[i] * @max_trade_size_eth
            elsif signal_down(@cursor)
                target_positions[i] = @asset_weights[i]*@max_trade_size_eth
            else 
                target_positions[i] = @positions[i][@cursor]
            end
        end

        @targets = target_positions
    end
    def generate_orders
        deltas = Array.new(@num_ownable_assets)
        for i in 0..(@num_ownable_assets-1)
            deltas[i] = @targets[i] - @positions[i][@cursor]
        end
        @orders = deltas
    end
    def execute_trades
        for i in 0..(@num_ownable_assets-1)
            @positions[i][@cursor] = @positions[i][@cursor-1]+@orders[i]
            @orders[i]=0
        end
    end
    def calculate_pnl
        @pnl[@cursor] = 0
        for i in 0..(@num_ownable_assets-1)
            @pnl[@cursor] += @positions[i][@cursor]*(@prices[i][@cursor]-@prices[i][@cursor-1])
            in_sample_flag = true
            if @starttimes[@cursor] > @model_endtime
                in_sample_flag=false
            end
        end
        ModeledSignal.find_or_create_by(
            starttime: @starttimes[@cursor],
            model_id: @model_id+"-b",
            resolution: @resolution,
            value: @pnl[@cursor],
            in_sample:in_sample_flag
        )
    end
    def set_initial_positions
        return unless @cursor == 0
        puts @positions.length()
        puts @positions[0].length()
        for i in 0..(@num_ownable_assets-1)
            @positions[i][@cursor] = 0
        end
    end

    def signal_up(index)
        returnVal = false
        if @signal[index]>@in_sample_mean + @in_sample_sd*@multiplier
            returnVal = true
        end
        return returnVal
    end
    def signal_down(index)
        returnVal = false
        if @signal[index]<@in_sample_mean - @in_sample_sd*@multiplier
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
            if @cursor==@num_obs 
                puts "reached end"
                break
            end
            self.execute_trades
            self.calculate_pnl
        end
        # puts "total profit: $" + @pnl.inject(:+).to_s
    end
end
