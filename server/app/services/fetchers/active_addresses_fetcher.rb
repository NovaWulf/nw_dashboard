module Fetchers
  class ActiveAddressesFetcher < MessariDataFetcher
    def initialize(token:)
      super(token: token, metric: 'active_addresses')
    end
  end
end
