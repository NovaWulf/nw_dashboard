class NonZeroAddressFetcher < GlassnodeFetcher
  def initialize
    super(token: 'btc', metric: 'non_zero_count')
  end
end
