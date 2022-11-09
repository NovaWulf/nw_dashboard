RSpec.describe Backtester do
  subject { described_class }
  let(:op_candle_first) { Candle.by_pair('op-usd').first&.close }
  let(:eth_candle_first) { Candle.by_pair('eth-usd').first&.close }
  let(:op_candle_second) { Candle.by_pair('op-usd').last&.close }
  let(:eth_candle_second) { Candle.by_pair('eth-usd').last&.close }
  let(:latest_model) { CointegrationModel.newest_first.first&.uuid }
  let(:log_prices) { CointegrationModel.newest_first.first&.log_prices }
  let(:op_weight) { CointegrationModelWeight.where("uuid = '#{latest_model}' and asset_name = 'op-usd'").first.weight }
  let(:eth_weight) do
    CointegrationModelWeight.where("uuid = '#{latest_model}' and asset_name = 'eth-usd'").first.weight
  end

  let(:pnl_expected_log) do
    - (op_weight / op_candle_first) * (op_candle_second - op_candle_first) - (eth_weight / eth_candle_first) * (eth_candle_second - eth_candle_first)
  end
  # suppose we have a signal from 2 time steps ago,
  # and candles, model from 1 timestep ago
  before(:each) do
    t_minus_1 = Time.now.to_i - 60
    t_minus_5 = Time.now.to_i - 300
    t_minus_10 = Time.now.to_i - 600
    t_minus_20 = Time.now.to_i - 1200
    Candle.create(starttime: t_minus_1,
                  pair: 'eth-usd',
                  exchange: 'Coinbase',
                  resolution: 60,
                  low: 1, high: 1, open: 1, close: 1, volume: 1)

    Candle.create(starttime: t_minus_1,
                  pair: 'op-usd',
                  exchange: 'Coinbase',
                  resolution: 60,
                  low: 3, high: 3, open: 3, close: 3, volume: 3)

    CointegrationModel.create(
      uuid: 'id1',
      timestamp: t_minus_10,
      ecdet: 'const',
      spec: 'transitory',
      cv_10_pct: 6,
      cv_5_pct: 7,
      cv_1_pct: 8,
      test_stat: 9,
      top_eig: 0.0008,
      resolution: 60,
      model_starttime: t_minus_20,
      model_endtime: t_minus_5,
      in_sample_mean: 0,
      in_sample_sd: 3,
      log_prices: true
    )
    BacktestModel.create(
      version: 0,
      model_id: 'id1',
      sequence_number: 0,
      name: 'seed_model',
      basket: 'OP_ETH'
    )
    ModeledSignal.create(
      starttime: t_minus_10,
      model_id: 'id1',
      resolution: 60,
      value: 5
    )
    CointegrationModelWeight.create(
      uuid: 'id2',
      timestamp: t_minus_10,
      asset_name: 'eth-usd',
      weight: 1
    )
    CointegrationModelWeight.create(
      uuid: 'id2',
      timestamp: t_minus_10,
      asset_name: 'op-usd',
      weight: -1
    )
    CointegrationModelWeight.create(
      uuid: 'id2',
      timestamp: t_minus_10,
      asset_name: 'det',
      weight: 0
    )

    CointegrationModel.create(
      uuid: 'id2',
      timestamp: t_minus_10,
      ecdet: 'const',
      spec: 'transitory',
      cv_10_pct: 6,
      cv_5_pct: 7,
      cv_1_pct: 8,
      test_stat: 9,
      top_eig: 0.0008,
      resolution: 60,
      model_starttime: t_minus_10,
      model_endtime: t_minus_1,
      in_sample_mean: 0,
      in_sample_sd: 3,
      log_prices: true
    )

    BacktestModel.create(
      version: 1,
      model_id: 'id2',
      sequence_number: 0,
      name: 'seed_model',
      basket: 'OP_ETH'
    )

    ModeledSignal.create(
      starttime: t_minus_10,
      model_id: 'id2',
      resolution: 60,
      value: 5
    )

    # NOTE: that the signal is high, meaning we should be
    # shorting ETH and going long OP. If the max absolute dollar amount for ETH
    # is $1000, and the price of eth is $1, this means being short 1000 eth.
    # At an OP price of $2, this is long 500 OP.
    # when op goes to 3, this position is worth 1500, or $500 more than before.
    # If ETH goes to 0, this position is now worth 1000 more than before.
    # so the total profit is $1500, or 1.5x, under the log-price model

    # NOTE: the value of this signal doesn't matter
    # it just needs to exist because the backtester using
    # the signal to calculate the number of observations
    Candle.create(starttime: Time.now.to_i,
                  pair: 'op-usd',
                  exchange: 'Coinbase',
                  resolution: 60,
                  low: 3, high: 3, open: 3, close: 3, volume: 3)
    Candle.create(starttime: Time.now.to_i,
                  pair: 'eth-usd',
                  exchange: 'Coinbase',
                  resolution: 60,
                  low: 0, high: 0, open: 0, close: 0, volume: 0)
    ModeledSignal.create(
      starttime: Time.now.to_i,
      model_id: 'id1',
      resolution: 60,
      value: 4
    )
    ModeledSignal.create(
      starttime: Time.now.to_i,
      model_id: 'id2',
      resolution: 60,
      value: 4
    )
    BacktestTrades.create(
      model_id: 'id1',
      signal_flag: 1,
      prev_signal_flag: 0,
      cursor: 0,
      starttime: t_minus_10,
      email_sent: true
    )
    BacktestTrades.create(
      model_id: 'id2',
      signal_flag: 1,
      prev_signal_flag: 0,
      cursor: 0,
      starttime: t_minus_1 + 60,
      email_sent: true
    )
  end

  it 'pnl calculation is accurate for log-price model' do
    expect { subject.run(version: 1, basket: 'OP_ETH', seq_num: nil, meta: false) }.to change {
                                                                                         ModeledSignal.where("model_id = 'id2-b'").count
                                                                                       }.by(1)
    m = ModeledSignal.last
    expect(m.value.round(1)).to eql pnl_expected_log.round(2)
  end

  it 'does not send subsequent email when signal stays high' do
    ModeledSignal.create(
      starttime: Time.now.to_i + 60,
      model_id: 'id2',
      resolution: 60,
      value: 2
    )

    Candle.create(starttime: Time.now.to_i + 60,
                  pair: 'op-usd',
                  exchange: 'Coinbase',
                  resolution: 60,
                  low: 3, high: 3, open: 3, close: 3, volume: 3)
    Candle.create(starttime: Time.now.to_i + 60,
                  pair: 'eth-usd',
                  exchange: 'Coinbase',
                  resolution: 60,
                  low: 0, high: 0, open: 0, close: 0, volume: 0)

    expect { subject.run(version: 1, basket: 'OP_ETH', seq_num: nil, meta: false) }.to change {
      ActionMailer::Base.deliveries.count
    }.by(0)
  end

  it 'does  send subsequent email when signal crosses 0 with out-of-sample first leg' do
    ModeledSignal.create(
      starttime: Time.now.to_i + 60,
      model_id: 'id2',
      resolution: 60,
      value: -4
    )

    Candle.create(starttime: Time.now.to_i + 60,
                  pair: 'op-usd',
                  exchange: 'Coinbase',
                  resolution: 60,
                  low: 3, high: 3, open: 3, close: 3, volume: 3)
    Candle.create(starttime: Time.now.to_i + 60,
                  pair: 'eth-usd',
                  exchange: 'Coinbase',
                  resolution: 60,
                  low: 0, high: 0, open: 0, close: 0, volume: 0)

    expect { subject.run(version: 1, basket: 'OP_ETH', seq_num: nil, meta: false) }.to change {
      ActionMailer::Base.deliveries.count
    }.by(1)
  end
end
