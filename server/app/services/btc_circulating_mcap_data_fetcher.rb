class BtcCirculatingMcapDataFetcher < MessariDataFetcher
  def initialize
    super(metric_key: 'btc_circ_mcap', metric_display_name: 'BTC Circulating Mcap')
  end
end
