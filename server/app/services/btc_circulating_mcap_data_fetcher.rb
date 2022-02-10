class BtcCirculatingMcapDataFetcher < MessariDataFetcher
  def initialize
    super(token: 'btc', metric: 'circ_mcap')
  end
end
