class MarketCapDisplayer < WeeklyValueDisplayer
  def initialize(token:)
    super(token: token, metric: 'circ_mcap')
  end
end
