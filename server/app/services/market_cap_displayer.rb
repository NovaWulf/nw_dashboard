class MarketCapDisplayer < BaseService
  attr_reader :token

  def initialize(token:)
    @token = token
  end

  def run
    Metric.by_token(token).by_metric('circ_mcap').mondays.oldest_first
  end
end
