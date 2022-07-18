RSpec.describe ArbitrageCalculator do
    subject { 
        described_class.run 
    }
    let(:op_candle) {Candle.by_pair("eth-usd").last&.close}
    let(:eth_candle) {Candle.by_pair("eth-usd").last&.close}
    let(:latest_model) {CointegrationModel.newest_first.first&.uuid}
    let(:op_weight) {CointegrationModelWeight.where("uuid = '#{latest_model}' and asset_name = 'op-usd'").first.weight}
    let(:eth_weight) {CointegrationModelWeight.where("uuid = '#{latest_model}' and asset_name = 'eth-usd'").first.weight}
    let(:const_weight) {CointegrationModelWeight.where("uuid = '#{latest_model}' and asset_name = 'det'").first.weight}
    
    let(:arb_signal_expected) do
        puts "op_weight: " + op_weight.to_s + " op_candle: " + op_candle.to_s + " eth_weight: " + eth_weight.to_s + " eth_candle: " + eth_candle.to_s + "const_wight: " + const_weight.to_s
        op_weight*op_candle +
        eth_weight*eth_candle + 
        const_weight
    end
    

    before(:each) do

        Candle.create(starttime: Time.now.to_i-60,
         pair: "op-usd",
         exchange: "Coinbase",
         resolution: 60,
         low: 1,high: 1,open: 1,close: 1,volume: 1 )

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
        thing= CointegrationModelWeight.last

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
        in_sample_sd: 100
        )

        ModeledSignal.create(
            starttime: Time.now.to_i-120, 
            model_id: "id1",
            resolution: 60,
            value: 10
        )
        
        allow_any_instance_of(described_class).to receive(:fetch_coinbase_data).and_return(true)
    end

   

    it 'persists' do
        expect { subject }.to change { ModeledSignal.count }.by(1)
        m = ModeledSignal.last
        expect(m.value.round(2)).to eql arb_signal_expected.round(2)
        expect(m.model_id).to eql "id1"
        expect(m.resolution).to eql 60
    end
    # note in_sample_mean=0,  in_sample_sd = 100,
    # and our op_weight=-1, eth weight = 1, const = 0
    # so with close prices of 100,100, our signal is 0
    context 'arb signal not in range' do
        it 'does not send email' do
            Candle.create(
                starttime: Time.now.to_i,
                pair: "op-usd",
                exchange: "Coinbase",
                resolution: 60,
                low: 100,high: 100,open: 100,close: 100,volume: 100
            )
            Candle.create(
                starttime: Time.now.to_i,
                pair: "eth-usd",
                exchange: "Coinbase",
                resolution: 60,
                low: 100,high: 100,open: 100,close: 100,volume: 100
            )
          expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(0)
        end
    end
    context 'arb signal in range' do
         
        it 'does send email' do
            Candle.create(
                starttime: Time.now.to_i,
                pair: "op-usd",
                exchange: "Coinbase",
                resolution: 60,
                low: 100,high: 100,open: 100,close: 100,volume: 100
            )
            Candle.create(
                starttime: Time.now.to_i,
                pair: "eth-usd",
                exchange: "Coinbase",
                resolution: 60,
                low: 300,high: 300,open: 300,close: 300,volume: 300
            )
          expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
        end
    end

   
  end
  