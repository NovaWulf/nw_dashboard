module Displayers
  class CointegrationModelWeightDisplayer < BaseService
  attr_reader :version, :sequence_number, :basket

  def initialize(version:, basket:, sequence_number: nil)
    @version = version
    @sequence_number = sequence_number
    @basket = basket
  end

  def run
    if sequence_number
      model = BacktestModel.where(version: version, basket: basket, sequence_number:sequence_number).oldest_sequence_number_first.last&.model_id
    else
      model = BacktestModel.where(version:version, basket: basket).oldest_sequence_number_first.last&.model_id
    end
    CointegrationModelWeight.where("uuid = '#{model}'").order_by_id
  end
end
end