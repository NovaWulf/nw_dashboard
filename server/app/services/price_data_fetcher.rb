class PriceDataFetcher < MessariDataFetcher
  def initialize(token:)
    super(token: token, metric: 'price')
  end
end
