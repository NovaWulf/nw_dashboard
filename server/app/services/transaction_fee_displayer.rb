class TransactionFeeDisplayer < WeeklySumDisplayer
  def initialize(token:)
    super(token: token, metric: 'transaction_fees')
  end
end
