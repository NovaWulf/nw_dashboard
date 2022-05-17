module Fetchers
  class RhodlFetcher < GlassnodeFetcher
  def initialize
    super(token: 'btc', metric: 'rhodl_ratio')
  end
end
end