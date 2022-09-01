module Displayers
  class PositionsDisplayer < BaseService
    attr_reader :model, :version, :sequence_number, :basket

    def initialize(version:, basket:, sequence_number: nil)
      @version = version
      @sequence_number = sequence_number
      @basket = basket
      if version
        if sequence_number
          Rails.logger.info "using #{sequence_number}-th model in sequence for v#{version} for displayer"
          model = BacktestModel.where("version=#{version} and basket = '#{basket}' and sequence_number=#{sequence_number}").last&.model_id
        else
          Rails.logger.info "using most recent in model in sequence for v#{version} for displayer"
          model = BacktestModel.where("version=#{version} and basket = '#{basket}'").oldest_sequence_number_first.last&.model_id
        end
      else
        Rails.logger.info 'using default model for displayer -- latest'
        model = BacktestModel.where("basket = '#{basket}'").oldest_version_first.last.oldest_sequence_number_first.last&.model_id
      end
      @model = model
    end

    def run
      Rails.logger.info "version: #{version}, basket: #{basket}, sequence_number: #{sequence_number}, model: #{model}"
      asset_names = CointegrationModelWeight.where("uuid = '#{@model}'").order_by_id.pluck(:asset_name)
      asset_names.delete_at(asset_names.index('det'))
      returnArray = []
      for a in asset_names do
        puts model+"-"+a
        thing = ModeledSignal.by_model(model+"-"+a).oldest_first.first&.value
        puts "count: #{thing}"
      end
      asset_names.map{|asset| ModeledSignal.by_model(model+"-"+asset).oldest_first}
    end
  end
end