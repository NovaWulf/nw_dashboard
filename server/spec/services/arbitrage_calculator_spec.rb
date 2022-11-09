RSpec.describe ArbitrageCalculator do
  subject { described_class.run(version: 2, basket: 'OP_ETH', seq_num: nil) }
  let(:op_candle) { Candle.by_pair('op-usd').last&.close }
  let(:eth_candle) { Candle.by_pair('eth-usd').last&.close }
  let(:latest_model) { CointegrationModel.newest_first.first&.uuid }
  let(:op_weight) do
    CointegrationModelWeight.where("uuid = '#{latest_model}' and asset_name = 'op-usd'").first.weight
  end
  let(:eth_weight) do
    CointegrationModelWeight.where("uuid = '#{latest_model}' and asset_name = 'eth-usd'").first.weight
  end
  let(:const_weight) do
    CointegrationModelWeight.where("uuid = '#{latest_model}' and asset_name = 'det'").first.weight
  end

  let(:arb_signal_expected) do
    op_weight * Math.log(op_candle) +
      eth_weight * Math.log(eth_candle) +
      const_weight
  end

  # suppose we have a signal from 2 time steps ago,
  # and candles, model from 1 timestep ago
  before(:each) do
    Candle.create(starttime: Time.now.to_i - 60,
                  pair: 'op-usd',
                  exchange: 'Coinbase',
                  resolution: 60,
                  low: Math.exp(2), high: Math.exp(2), open: Math.exp(2), close: Math.exp(2), volume: Math.exp(2))

    Candle.create(starttime: Time.now.to_i - 60,
                  pair: 'eth-usd',
                  exchange: 'Coinbase',
                  resolution: 60,
                  low: Math.exp(1), high: Math.exp(1), open: Math.exp(1), close: Math.exp(1), volume: Math.exp(1))

    CointegrationModelWeight.create(
      uuid: 'id1',
      timestamp: 1_800_000_000,
      asset_name: 'op-usd',
      weight: -1
    )
    CointegrationModelWeight.create(
      uuid: 'id1',
      timestamp: 1_800_000_000,
      asset_name: 'eth-usd',
      weight: 1
    )
    CointegrationModelWeight.create(
      uuid: 'id1',
      timestamp: 1_800_000_000,
      asset_name: 'det',
      weight: 0
    )

    CointegrationModel.create(
      uuid: 'id1',
      timestamp: 1_800_000_000,
      ecdet: 'const',
      spec: 'transitory',
      cv_10_pct: 6,
      cv_5_pct: 7,
      cv_1_pct: 8,
      test_stat: 9,
      top_eig: 0.0008,
      resolution: 60,
      model_starttime: 1_600_000_000,
      model_endtime: 1_700_000_000,
      in_sample_mean: 0,
      in_sample_sd: 100,
      log_prices: true
    )

    BacktestModel.create(
      version: 2,
      model_id: 'id1',
      sequence_number: 0,
      name: 'seed_model',
      basket: 'OP_ETH'
    )

    ModeledSignal.create(
      starttime: Time.now.to_i - 120,
      model_id: 'id1',
      resolution: 60,
      value: 10
    )
  end

  it 'persists' do
    expect { subject }.to change { ModeledSignal.count }.by(1)
    m = ModeledSignal.last
    expect(m.value.round(2)).to eql arb_signal_expected.round(2)
    expect(m.model_id).to eql 'id1'
    expect(m.resolution).to eql 60
  end
  # NOTE: in_sample_mean=0,  in_sample_sd = 100,
  # and our op_weight=-1, eth weight = 1, const = 0
  # so with close prices of 100,100, our signal is 0
  # and with 300,100, our signal = 200 > in_sample_mean+in_sample_sd
  context 'arb signal not in range' do
    let!(:op_candle_new) do
      Candle.create(
        starttime: Time.now.to_i,
        pair: 'op-usd',
        exchange: 'Coinbase',
        resolution: 60,
        low: Math.exp(100), high: Math.exp(100), open: Math.exp(100), close: Math.exp(100), volume: Math.exp(100)
      )
    end
    let!(:eth_candle_new) do
      Candle.create(
        starttime: Time.now.to_i,
        pair: 'eth-usd',
        exchange: 'Coinbase',
        resolution: 60,
        low: Math.exp(90), high: Math.exp(90), open: Math.exp(90), close: Math.exp(90), volume: Math.exp(90)
      )
    end
    it 'does not send email' do
      expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(0)
    end
  end
  context 'arb signal in range' do
    let!(:op_candle_create_new2) do
      Candle.create(
        starttime: Time.now.to_i,
        pair: 'op-usd',
        exchange: 'Coinbase',
        resolution: 60,
        low: Math.exp(101), high: Math.exp(101), open: Math.exp(101), close: Math.exp(101), volume: Math.exp(101)
      )
    end
    let!(:eth_candle_create_new2) do
      Candle.create(
        starttime: Time.now.to_i,
        pair: 'eth-usd',
        exchange: 'Coinbase',
        resolution: 60,
        low: Math.exp(300), high: Math.exp(300), open: Math.exp(300), close: Math.exp(300), volume: Math.exp(300)
      )
    end
    it 'does send email' do
      expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
