module Displayers
    class DailyValueDisplayer < BaseService
      attr_reader :model 

      def initialize(model:)
        if !model
          puts "using default model for displayer -- latest"
          model = CointegrationModel.newest_first.first&.uuid
        end
        @model = model
        puts "model: " + model.to_s
      end
  
      def run
        ModeledSignal.by_model(@model).at_noon.on_the_hour.oldest_first
      end
    end
  end
  