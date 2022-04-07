class CirculatingSupplyDisplayer < BaseService
  attr_reader :token

  def initialize(token:)
    @token = token
  end

  def run
    Metric.by_token(token).by_metric('circ_supply').sundays.oldest_first
  end
end
