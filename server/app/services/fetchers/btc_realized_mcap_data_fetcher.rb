module Fetchers
  class BtcRealizedMcapDataFetcher < MessariDataFetcher
    def initialize
      super(token: 'btc', metric: 'realized_mcap')
    end
  end
end
