module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    field :mvrv, [Types::MetricType], null: false, description: 'Return a list of mvrv metrics'
    field :btc, [Types::MetricType], null: false, description: 'Return a list of btc metrics'

    def mvrv
      # grab only sundays for weekly data
      Metric.where(name: 'btc_mvrv').where('extract(DOW from timestamp) = ?', 0)
    end

    def btc
      Metric.where(name: 'btc_price').where('extract(DOW from timestamp) = ?', 0)
    end
  end
end
