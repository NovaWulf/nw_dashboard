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

    field :transaction_count, [Types::MetricType], null: false do
      argument :token, String
    end

    field :market_cap, [Types::MetricType], null: false do
      argument :token, String
    end

    field :circ_supply, [Types::MetricType], null: false do
      argument :token, String
    end

    field :mcap_dominance, [Types::MetricType], null: false do
      argument :token, String
    end

    field :token_price, [Types::MetricType], null: false do
      argument :token, String
    end

    field :volume, [Types::MetricType], null: false do
      argument :token, String
    end

    field :transaction_fees, [Types::MetricType], null: false do
      argument :token, String
    end

    field :dev_activity, [Types::MetricType], null: false do
      argument :token, String
    end

    field :santiment_dev_activity, [Types::MetricType], null: false do
      argument :token, String
    end

    def btc_mvrv
      Displayers::WeeklyValueDisplayer.run(token: 'btc', metric: 'mvrv')
    end

    def rhodl_ratio
      Displayers::WeeklyValueDisplayer.run(token: 'btc', metric: 'rhodl_ratio')
    end

    def token_price(token:)
      Displayers::PriceDisplayer.run(token: token).value
    end

    def volume(token:)
      Displayers::VolumeDisplayer.run(token: token).value
    end

    def transaction_fees(token:)
      Displayers::TransactionFeeDisplayer.run(token: token).value
    end

    def active_addresses(token:)
      Displayers::ActiveAddressDisplayer.run(token: token).value
    end

    def transaction_count(token:)
      Displayers::TransactionCountDisplayer.run(token: token).value
    end

    def market_cap(token:)
      Displayers::MarketCapDisplayer.run(token: token).value
    end

    def mcap_dominance(token:)
      Displayers::MarketCapDominanceDisplayer.run(token: token).value
    end

    def circ_supply(token:)
      Displayers::CirculatingSupplyDisplayer.run(token: token).value
    end

    def dev_activity(token:)
      Displayers::ActivityDisplayer.run(token: token).value
    end

    def santiment_dev_activity(token:)
      Displayers::SantimentActivityDisplayer.run(token: token).value
    end

    def jesse
      Displayers::WeeklyValueDisplayer.run(token: 'btc', metric: 'jesse')
    end
  end
end
