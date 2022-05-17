class PriceDisplayer < WeeklyValueDisplayer
  def initialize(token:)
    super(token: token, metric: 'price')
  end
end
