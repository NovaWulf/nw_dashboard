module Fetchers
  class FullyDilutedMarketCapFetcher < MessariDataFetcher
    def initialize(token:)
      super(token: token, metric: 'fully_diluted_mcap')
    end
  end
end
