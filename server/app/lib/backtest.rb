class Backtest
    @model
    @assets
    def initialize 
        @positions = [[]]
        @assets = []
    end
    def load_model(model_id:)
        @model = CointegrationModel.where("uuid = '#{model_id}''").last
        weights = CointegrationModelWeights.where("uuid = '#{model_id}'")
        puts "number of weights for model: " + weights.count.to_s
        @assets = weights.pluck(:asset_name)
        puts "assets: " + @assets.to_s
    end
    def generate_positions()
        #do stuff
    end
end
