class BtcRealizedMcapDataFetcher < MessariDataFetcher
  def initialize
    super(metric_key: 'btc_realized_mcap', metric_display_name: 'BTC Realized Mcap')
  end
end
