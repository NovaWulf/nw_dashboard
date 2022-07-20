class Backtest
    @assets
    @ownable_assets
    @asset_weights
    @cursor
    @starttime
    @signal
    @in_sample_mean
    @multiplier
    @max_trade_size_eth
    @positions
    def initialize 
        @cursor = 0
        @multiplier = 1.0
        @max_trade_size_eth = 1000
    end
    def load_model(model_id:)
        model = CointegrationModel.where("uuid = '#{model_id}'").last
        @starttime = model&.model_starttime
        @in_sample_sd = model&.in_sample_sd
        @in_sample_mean = model&.in_sample_mean

        weights = CointegrationModelWeight.where("uuid = '#{model_id}'")
        puts "number of weights for model: " + weights.count.to_s
        @assets = weights.pluck(:asset_name)
        @asset_weights = weights.pluck(:weights)
        puts "assets: " + @assets.to_s
        @ownable_assets = @assets.delete("det")
        numOwnableAssets = @ownable_assets.length()
        
        puts "model starttime: " + @starttime.to_s
        @signal = ModeledSignal.where("model_id = '#{model_id}'").oldest_first.pluck(:value)
        @positions = Array.new(@signal.length()){Array.new(numOwnableAssets)}
        @pnl = Array.new(@signal.length())
        @transactions = Array.new(@signal.length())
    end
    def generate_positions()
        #do stuff
    end
    def set_initial_positions()
        for i in 0..numOwnableAssets
            positions[@cursor][i] = 0
            if signal_up
                @positions[0][i] = 
            end
        end
    end

    def signal_up()
        returnVal = false
        if signal[@cursor]>@in_sample_mean + @in_sample_sd*@multiplier
            returnVal = true
        end
        return returnVal
    end
    def signal_down()
        returnVal = false
        if signal[@cursor]<@in_sample_mean - @in_sample_sd*@multiplier
            returnVal = true
        end
        return returnVal
    end
end
