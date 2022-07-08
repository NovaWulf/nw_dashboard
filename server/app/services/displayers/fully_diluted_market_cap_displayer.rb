module Displayers
  class FullyDilutedMarketCapDisplayer < WeeklyValueDisplayer
    def initialize(token:)
      super(token: token, metric: 'fully_diluted_mcap')
    end
  end
end
