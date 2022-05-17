module Fetchers
  class SmartContractTransactionCountFetcher < MessariDataFetcher
    def initialize(token:)
      super(token: token, metric: 'smart_contract_txn_count')
    end
  end
end
