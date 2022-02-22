class S2fFetcher < GlassnodeFetcher
  attr_reader :token

  def initialize
    super(token: 'btc', metric: 's2f_ratio')
  end

  def value(m)
    m['o']['ratio']
  end
end
