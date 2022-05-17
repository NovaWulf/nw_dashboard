module Fetchers
  class MarketCapDominanceFetcher < MessariDataFetcher
    def initialize(token:)
      super(token: token, metric: 'mcap_dominance')
    end
  end
end
