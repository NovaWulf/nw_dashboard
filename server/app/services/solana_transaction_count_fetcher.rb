class SolanaTransactionCountFetcher < BitqueryFetcher
  def initialize
    super(token: 'sol', metric: 'transaction_count')
  end
end
