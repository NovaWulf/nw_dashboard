module Displayers
  class TransactionCountDisplayer < WeeklyValueDisplayer
  def initialize(token:)
    super(token: token, metric: 'transaction_count')
  end
end
end