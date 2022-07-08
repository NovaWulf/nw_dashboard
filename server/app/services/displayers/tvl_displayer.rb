module Displayers
  class TvlDisplayer < WeeklySumDisplayer
    def initialize(token:)
      super(token: token, metric: 'tvl')
    end
  end
end
