module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    field :mvrv, [Types::MetricType], null: false, description: 'Return a list of mvrv metrics'
    field :btc, [Types::MetricType], null: false, description: 'Return a list of btc metrics'

    def mvrv
      # grab only sundays for weekly data
      Metric.by_metric('btc_mvrv').sundays
    end

    def btc
      Metric.by_metric('btc_price').sundays
    end
  end
end
