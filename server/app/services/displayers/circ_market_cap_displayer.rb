module Displayers
  class CircMarketCapDisplayer < WeeklyValueDisplayer
    def initialize(token:)
      super(token: token, metric: 'circ_mcap')
    end
  end
end
