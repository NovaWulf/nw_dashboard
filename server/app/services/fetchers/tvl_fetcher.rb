module Fetchers
  class TvlFetcher < TokenTerminalFetcher
    def initialize(token:)
      super(token: token, metric: 'tvl')
    end
  end
end
