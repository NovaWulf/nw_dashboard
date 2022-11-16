module Displayers
  class MetaBreakpointsDisplayer < BaseService
  attr_reader :version, :basket

  def initialize(version:, basket:)
    @version = version
    @basket = basket
  end

  def run
    resultArray = []
    max_seq_num = BacktestModel.where("version=#{version} and basket='#{basket}'").oldest_sequence_number_first.last&.sequence_number
    (0..max_seq_num).map do |seq_num|
      model = BacktestModel.where(version:version, basket: basket,sequence_number:seq_num).last&.model_id
      resultArray.append(CointegrationModel.where("uuid = '#{model}'").first)
    end
    resultArray
  end
end
end