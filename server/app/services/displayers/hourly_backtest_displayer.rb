module Displayers
  class HourlyBacktestDisplayer < BaseService
    attr_reader :model

    def initialize(version)
      if version
        Rails.logger.info "using most recent in model in sequence for v#{version} for displayer"
        model = BacktestModel.where("version=#{version}").oldest_sequence_number_first.last&.model_id
      else
        Rails.logger.info 'using default model for displayer -- latest'
        model = BacktestModel.oldest_version_first.oldest_sequence_number_first.last&.model_id
      end
      @model = model
    end

    def run
      puts "version: #{model}"
      ModeledSignal.by_model(model + '-b').on_the_hour.oldest_first
    end
  end
end
