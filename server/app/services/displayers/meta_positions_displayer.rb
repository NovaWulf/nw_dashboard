module Displayers
  class MetaPositionsDisplayer < BaseService
    attr_reader :last_model, :version, :basket

    def initialize(version:, basket:)
      @version = version
      @basket = basket
      @last_model
      if !version
        Rails.logger.info 'using default model for displayer -- latest'
        version = BacktestModel.where("basket = '#{basket}'").oldest_version_first.last.oldest_sequence_number_first.last&.version
      end 
      @last_model = BacktestModel.where("basket = '#{basket}' and version=#{version}").oldest_sequence_number_first.last&.model_id
    end

    def run
      Rails.logger.info "version: #{version}, basket: #{basket},  last_model: #{last_model}"
      asset_names = CointegrationModelWeight.where("uuid = '#{last_model}'").order_by_id.pluck(:asset_name)
      asset_names.delete_at(asset_names.index('det'))
      asset_names.map{|asset| ModeledSignal.by_model("v#{version}-#{basket}-meta-#{asset}").oldest_first}
    end
  end
end