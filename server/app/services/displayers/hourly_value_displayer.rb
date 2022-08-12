module Displayers
  class HourlyValueDisplayer < BaseService
    attr_reader :model, :version, :sequence_number

    def initialize(version:, sequence_number: nil)
      @version = version
      @sequence_number = sequence_number
      if version
        if sequence_number
          Rails.logger.info "using #{sequence_number}-th model in sequence for v#{version} for displayer"
          model = BacktestModel.where("version=#{version} and sequence_number=#{sequence_number}").last&.model_id
        else
          Rails.logger.info "using most recent in model in sequence for v#{version} for displayer"
          model = BacktestModel.where("version=#{version}").oldest_sequence_number_first.last&.model_id
        end
      else
        Rails.logger.info 'using default model for displayer -- latest'
        model = BacktestModel.oldest_version_first.last.oldest_sequence_number_first.last&.model_id
      end
      @model = model
    end

    def run
      Rails.logger.info "version: #{version}, sequence_number: #{sequence_number}, model: #{model}"
      ModeledSignal.by_model(model).on_the_hour.oldest_first
    end
  end
end
