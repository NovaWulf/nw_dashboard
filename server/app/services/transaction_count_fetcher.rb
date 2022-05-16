class TransactionCountFetcher < MessariDataFetcher
  def initialize(token:)
    super(token: token, metric: 'transaction_count')
  end
end
