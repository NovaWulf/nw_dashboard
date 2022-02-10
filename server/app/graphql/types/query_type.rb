module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    field :btc_mvrv, [Types::MetricType], null: false, description: 'Returns BTC MVRV by week'
    field :btc_price, [Types::MetricType], null: false, description: 'Return BTC price by week'
    field :eth_price, [Types::MetricType], null: false, description: 'Return ETH price by week'
    field :btc_active_addresses, [Types::MetricType], null: false,
                                                      description: 'Return BTC active addresses by week'
    field :btc_dev_activity, [Types::MetricType], null: false,
                                                  description: 'Return BTC dev activity summed by week'

    field :eth_dev_activity, [Types::MetricType], null: false,
                                                  description: 'Return ETH dev activity summed by week'

    def btc_mvrv
      # grab only sundays for weekly data
      Metric.by_token('btc').by_metric('mvrv').sundays
    end

    def btc_price
      Metric.by_token('btc').by_metric('price').sundays
    end

    def eth_price
      Metric.by_token('eth').by_metric('price').sundays
    end

    def btc_active_addresses
      Metric.by_token('btc').by_metric('active_addresses').sundays
    end

    def btc_dev_activity
      Metric.by_token('btc').by_metric('dev_activity').group_by_week(:timestamp).sum(:value).to_a.map do |m|
        OpenStruct.new(timestamp: m[0], value: m[1])
      end
    end

    def eth_dev_activity
      Metric.by_token('eth').by_metric('dev_activity').group_by_week(:timestamp).sum(:value).to_a.map do |m|
        OpenStruct.new(timestamp: m[0], value: m[1])
      end
    end
  end
end
