module Fetchers
  class HashRateFetcher < GlassnodeFetcher
    def initialize
      super(token: 'btc', metric: 'hash_rate')
    end
  end
end
