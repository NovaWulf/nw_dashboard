module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    field :btc_mvrv, [Types::MetricType], null: false
    field :rhodl_ratio, [Types::MetricType], null: false
    field :jesse, [Types::MetricType], null: false

    field :backtest_latest_model, [Types::ModeledSignalType], null: false do
      argument :version, Integer
      argument :basket, String
    end

    field :dual_candle_charts, [[Types::CandleType]], null: false do
      argument :version, Integer
      argument :sequence_number, Integer, required: false
      argument :basket, String
    end

    field :backtest_model, [Types::ModeledSignalType], null: false do
      argument :version, Integer
      argument :sequence_number, Integer, required: false
      argument :basket, String
    end

    field :backtest_positions, [[Types::ModeledSignalType]], null: false do
      argument :version, Integer
      argument :sequence_number, Integer, required: false
      argument :basket, String
    end

    field :backtest_model_info, [Types::BacktestModelType], null: false do
      argument :version, Integer
      argument :basket, String
    end

    field :arb_signal_latest_model, [Types::ModeledSignalType], null: false do
      argument :version, Integer
      argument :basket, String
    end

    field :arb_signal_model, [Types::ModeledSignalType], null: false do
      argument :version, Integer
      argument :sequence_number, Integer, required: false
      argument :basket, String
    end

    field :cointegration_model_info, [Types::CointegrationModelType], null: false do
      argument :version, Integer
      argument :sequence_number, Integer, required: false
      argument :basket, String
    end
    field :cointegration_model_weights, [Types::CointegrationModelWeightType], null: false do
      argument :version, Integer
      argument :sequence_number, Integer, required: false
      argument :basket, String
    end

    field :smart_contract_active_users, [Types::MetricType], null: false do
      argument :token, String
    end

    field :smart_contract_contracts, [Types::MetricType], null: false do
      argument :token, String
    end

    field :active_addresses, [Types::MetricType], null: false do
      argument :token, String
    end

    field :transaction_count, [Types::MetricType], null: false do
      argument :token, String
    end

    field :circ_market_cap, [Types::MetricType], null: false do
      argument :token, String
    end

    field :fully_diluted_market_cap, [Types::MetricType], null: false do
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

    field :tvl, [Types::MetricType], null: false do
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
      Displayers::WeeklyValueDisplayer.run(token: 'btc', metric: 'mvrv').value
    end

    def rhodl_ratio
      Displayers::WeeklyValueDisplayer.run(token: 'btc', metric: 'rhodl_ratio').value
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

    def circ_market_cap(token:)
      Displayers::CircMarketCapDisplayer.run(token: token).value
    end

    def fully_diluted_market_cap(token:)
      Displayers::FullyDilutedMarketCapDisplayer.run(token: token).value
    end

    def mcap_dominance(token:)
      Displayers::MarketCapDominanceDisplayer.run(token: token).value
    end

    def circ_supply(token:)
      Displayers::CirculatingSupplyDisplayer.run(token: token).value
    end

    def tvl(token:)
      Displayers::TvlDisplayer.run(token: token).value
    end

    def dev_activity(token:)
      Displayers::ActivityDisplayer.run(token: token).value
    end

    def santiment_dev_activity(token:)
      Displayers::SantimentActivityDisplayer.run(token: token).value
    end

    def jesse
      Displayers::WeeklyValueDisplayer.run(token: 'btc', metric: 'jesse').value
    end

    def dual_candle_charts(version:, basket:, sequence_number: nil)
      Displayers::DualCandleDisplayer.run(version: version, basket: basket, sequence_number: sequence_number).value
    end

    def cointegration_model_info(version:, basket:, sequence_number: nil)
      Displayers::CointegrationModelDisplayer.run(version: version, basket: basket,
                                                  sequence_number: sequence_number).value
    end

    def cointegration_model_weights(version:, basket:, sequence_number: nil)
      Displayers::CointegrationModelWeightDisplayer.run(version: version, basket: basket,
                                                        sequence_number: sequence_number).value
    end

    def backtest_model_info(version:, basket:)
      [BacktestModel.where("version=#{version} and basket = '#{basket}'").oldest_sequence_number_first.last]
    end

    def arb_signal_latest_model(version:, basket:)
      Displayers::HourlyValueDisplayer.run(version: version, basket: basket, sequence_number: nil).value
    end

    def backtest_latest_model(version:, basket:)
      Displayers::BacktestDisplayer.run(version: version, basket: basket, sequence_number: nil).value
    end

    def arb_signal_model(version:, basket:, sequence_number: nil)
      Displayers::HourlyValueDisplayer.run(version: version, basket: basket, sequence_number: sequence_number).value
    end

    def backtest_model(version:, basket:, sequence_number: nil)
      Displayers::BacktestDisplayer.run(version: version, basket: basket, sequence_number: sequence_number).value
    end

    def backtest_positions(version:, basket:, sequence_number: nil)
      Displayers::PositionsDisplayer.run(version: version, basket: basket, sequence_number: sequence_number).value
    end

    def smart_contract_contracts(token:)
      Displayers::WeeklyValueDisplayer.run(token: token, metric: 'smart_contract_contracts').value
    end

    def smart_contract_active_users(token:)
      Displayers::WeeklyValueDisplayer.run(token: token, metric: 'smart_contract_active_users').value
    end
  end
end
