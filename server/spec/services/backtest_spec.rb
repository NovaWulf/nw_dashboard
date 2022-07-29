RSpec.describe Backtest do
  subject(:instance) { described_class.new }
 
  let(:op_candle_first) {Candle.by_pair("op-usd").first&.close}
  let(:eth_candle_first) {Candle.by_pair("eth-usd").first&.close}
  let(:op_candle_second) {Candle.by_pair("op-usd").last&.close}
  let(:eth_candle_second) {Candle.by_pair("eth-usd").last&.close}

  let(:latest_model) {CointegrationModel.newest_first.first&.uuid}
  let(:op_weight) {CointegrationModelWeight.where("uuid = '#{latest_model}' and asset_name = 'op-usd'").first.weight}
  let(:eth_weight) {CointegrationModelWeight.where("uuid = '#{latest_model}' and asset_name = 'eth-usd'").first.weight}
  
  let(:pnl_expected) do
      - 1000 * op_weight * (op_candle_second - op_candle_first)-  1000 * eth_weight * (eth_candle_second - eth_candle_first)
  end
  

  # suppose we have a signal from 2 time steps ago,
  # and candles, model from 1 timestep ago
  before(:each) do

      Candle.create(starttime: Time.now.to_i-60,
       pair: "op-usd",
       exchange: "Coinbase",
       resolution: 60,
       low: 2,high: 2,open: 2,close: 2,volume: 2 )

      Candle.create(starttime: Time.now.to_i-60,
       pair: "eth-usd",
       exchange: "Coinbase",
       resolution: 60,
       low: 1,high: 1,open: 1,close: 1,volume: 1 )

      CointegrationModelWeight.create(
          uuid: "id1", 
          timestamp: 1800000000,
          asset_name: "op-usd", 
          weight: -1 ) 

      CointegrationModelWeight.create(
          uuid: "id1", 
          timestamp: 1800000000,
          asset_name: "eth-usd", 
          weight: 1 
      ) 
      CointegrationModelWeight.create(
          uuid: "id1", 
          timestamp: 1800000000,
          asset_name: "det", 
          weight: 0 
      ) 

      CointegrationModel.create(
      uuid: "id1", 
      timestamp: 1800000000,
      ecdet: "const", 
      spec: "transitory",
      cv_10_pct: 6,
      cv_5_pct: 7,
      cv_1_pct: 8,
      test_stat: 9,
      top_eig: 0.0008,
      resolution: 60,
      model_starttime: 1600000000,
      model_endtime: 1700000000,
      in_sample_mean: 0,
      in_sample_sd: 5
      )

      BacktestModel.create(
        version: 0,
        model_id: "id1",
        sequence_number: 0,
        name: "seed_model"
      )

      ModeledSignal.create(
          starttime: Time.now.to_i-60, 
          model_id: "id1",
          resolution: 60,
          value: 10
      )

      # note that the signal is high, meaning we should be 
      # shorting 1000 ETH and going long 1000 OP

      Candle.create(starttime: Time.now.to_i,
        pair: "op-usd",
        exchange: "Coinbase",
        resolution: 60,
        low: 3,high: 3,open: 3,close: 3,volume: 3 )
 
      Candle.create(starttime: Time.now.to_i,
        pair: "eth-usd",
        exchange: "Coinbase",
        resolution: 60,
        low: 0,high: 0,open: 0,close: 0,volume: 0 )

      #note the value of this signal doesn't matter
      # it just needs to exist because the backtester using
      # the signal to calculate the number of observations
      ModeledSignal.create(
            starttime: Time.now.to_i, 
            model_id: "id1",
            resolution: 60,
            value: 3
        )
      
  end

 

  it 'persists' do
      expect { instance.run }.to change { ModeledSignal.where("model_id = 'id1-b'").count }.by(1)
      m = ModeledSignal.last
      expect(m.value.round(2)).to eql pnl_expected.round(2)
  end
  

 
end
