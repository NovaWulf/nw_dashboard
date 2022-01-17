class BtcPriceDataFetcher < MessariDataFetcher
  def initialize
    super(metric_key: 'btc_price', metric_display_name: 'BTC Price')
  end
end
