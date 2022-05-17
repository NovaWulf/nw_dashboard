module Displayers
  class ActiveAddressDisplayer < WeeklyValueDisplayer
    def initialize(token:)
      super(token: token, metric: 'active_addresses')
    end
  end
end
