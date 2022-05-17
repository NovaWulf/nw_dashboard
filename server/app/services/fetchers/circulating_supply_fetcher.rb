module Fetchers
  class CirculatingSupplyFetcher < MessariDataFetcher
  def initialize(token:)
    super(token: token, metric: 'circ_supply')
  end
end
end