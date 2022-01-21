class BtcActiveAddressesFetcher < MessariDataFetcher
  def initialize
    super(metric_key: 'btc_active_addresses', metric_display_name: 'BTC Active Addresses')
  end
end
