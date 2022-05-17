class TransactionFeeFetcher < GlassnodeFetcher
  def initialize(token:)
    super(token: token, metric: 'transaction_fees')
  end
end
