class SolanaActiveAddressesFetcher < BitqueryFetcher
  def initialize
    super(token: 'sol', metric: 'active_addresses')
  end
end
