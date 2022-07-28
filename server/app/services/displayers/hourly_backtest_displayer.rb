module Displayers
  class HourlyBacktestDisplayer < BaseService
    attr_reader :model 

    def initialize(model:)
      if !model
        Rails.logger.info "using default model for displayer -- latest"
        model = CointegrationModel.newest_first.first&.uuid
      end
      @model = model
    end

    def run()
      ModeledSignal.by_model(model+"-b").on_the_hour.oldest_first
    end

  end
end