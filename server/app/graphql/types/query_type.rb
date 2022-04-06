module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    field :btc_mvrv, [Types::MetricType], null: false
    field :rhodl_ratio, [Types::MetricType], null: false
    field :jesse, [Types::MetricType], null: false

    field :active_addresses, [Types::MetricType], null: false do
      argument :token, String
    end

    field :market_cap, [Types::MetricType], null: false do
      argument :token, String
    end

    field :token_price, [Types::MetricType], null: false do
      argument :token, String
    end

    field :volume, [Types::MetricType], null: false do
      argument :token, String
    end

    field :dev_activity, [Types::MetricType], null: false do
      argument :token, String
    end

    field :santiment_dev_activity, [Types::MetricType], null: false do
      argument :token, String
    end

    def btc_mvrv
      Metric.by_token('btc').by_metric('mvrv').sundays.oldest_first
    end

    def rhodl_ratio
      Metric.by_token('btc').by_metric('rhodl_ratio').sundays.oldest_first
    end

    def token_price(token:)
      PriceDisplayer.run(token: token).value
    end

    def volume(token:)
      VolumeDisplayer.run(token: token).value
    end

    def active_addresses(token:)
      ActiveAddressDisplayer.run(token: token).value
    end

    def market_cap(token:)
      MarketCapDisplayer.run(token: token).value
    end

    def dev_activity(token:)
      ActivityDisplayer.run(token: token).value
    end

    def santiment_dev_activity(token:)
      SantimentActivityDisplayer.run(token: token).value
    end

    def jesse
      Metric.by_token('btc').by_metric('jesse').sundays.oldest_first
    end
  end
end
