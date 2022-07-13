module Displayers
    class DailyValueDisplayer < BaseService
      attr_reader :model 

      def initialize(model:)
        @model = model
      end
  
      def run
        ModeledSignal.by_model(model).at_noon.on_the_hour.oldest_first
      end
    end
  end
  