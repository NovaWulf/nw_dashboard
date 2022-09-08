module Displayers
  class DualCandleDisplayer < BaseService
    attr_reader :basket, :version, :sequence_number, :asset_1, :asset_2

    def initialize(version:, basket:, sequence_number: nil)
      @basket = basket
      @sequence_number = sequence_number
      @basket = basket
      if version
        if sequence_number
          model = BacktestModel.where("version=#{version} and basket = '#{basket}' and sequence_number=#{sequence_number}").last&.model_id
        else
          model = BacktestModel.where("version=#{version} and basket = '#{basket}'").oldest_sequence_number_first.last&.model_id
        end
      else
        model = BacktestModel.where("basket = '#{basket}'").oldest_version_first.last.oldest_sequence_number_first.last&.model_id
      end
      @model = model
    end

    def run
      starttime = @model&.model_starttime
      asset_names = CointegrationModelWeight.where("uuid = '#{@model}'").order_by_id.pluck(:asset_name)
      asset_names.delete_at(asset_names.index('det'))
      asset_names.map { |asset| Candle.where(starttime: starttime).by_pair(asset).oldest_first.on_the_hour }
    end
  end
end
