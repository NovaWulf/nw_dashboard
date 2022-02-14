module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    field :btc_mvrv, [Types::MetricType], null: false

    field :active_addresses, [Types::MetricType], null: false do
      argument :token, String
    end

    field :token_price, [Types::MetricType], null: false do
      argument :token, String
    end

    field :dev_activity, [Types::MetricType], null: false do
      argument :token, String
    end

    def btc_mvrv
      # grab only mondays for weekly data
      Metric.by_token('btc').by_metric('mvrv').mondays.oldest_first
    end

    def token_price(token:)
      Metric.by_token(token).by_metric('price').mondays.oldest_first
    end

    def active_addresses(token:)
      Metric.by_token(token).by_metric('active_addresses').mondays.oldest_first
    end

    def dev_activity(token:)
      Metric.by_token(token).by_metric('dev_activity').oldest_first.group_by_week(:timestamp).sum(:value).to_a.map do |m|
        OpenStruct.new(timestamp: m[0], value: m[1])
      end
    end
  end
end
