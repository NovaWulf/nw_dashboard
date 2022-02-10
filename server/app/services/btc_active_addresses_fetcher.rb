class BtcActiveAddressesFetcher < MessariDataFetcher
  def initialize
    super(token: 'btc', metric: 'active_addresses')
  end
end
