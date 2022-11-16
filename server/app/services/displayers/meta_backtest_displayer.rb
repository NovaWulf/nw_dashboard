module Displayers
  class MetaBacktestDisplayer < BaseService
    attr_reader :model, :version, :basket

    def initialize(version:, basket:)
      @version = version
      @basket = basket
      if !version
        Rails.logger.info 'using default model for displayer -- latest'
        version = BacktestModel.where("basket='#{basket}'").oldest_version_first.oldest_sequence_number_first.last&.version       
      end
    end

    def run
      Rails.logger.info "basket: #{basket}, version: #{version}"
      ModeledSignal.by_model("v#{version}-#{basket}-meta").oldest_first
    end
  end
end
