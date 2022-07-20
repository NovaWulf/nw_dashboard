class Backtest
    @signal
    @in_sample_mean
    @in_sample_sd
    @in_sample_endtime
    def initialize
        positions = []
        
        puts "initializing"
    end
    def load_model(model_id:)
        model = CointegrationModel.where("uuid = '#{model_id}'").last

        @in_sample_mean = model&.in_sample_mean
        @in_sample_sd = model&.in_sample_sd
        @in_sample_endtime = model&.model_endtime
        @signal = ModeledSignal.where("uuid = '#{model_id}'").oldest_first
    end

    def generate_positions

        starttimes.each do |time|
    end 

end