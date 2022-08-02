RSpec.describe Fetchers::CoinbaseFetcher do
    subject { described_class.run(resolution: 60, pair: "op-usd") }
    include_context 'coinbase client'
  
    it 'persists' do
      subject
      expect(Candle.count).to eql 1
      m = Candle.first
      expect(m.volume).to eql 100.0
      expect(m.open).to eql 100.0
      expect(m.high).to eql 100.0
      expect(m.close).to eql 100.0
      expect(m.low).to eql 100.0
      expect(m.pair).to eql "op-usd"
      expect(m.resolution).to eql 60
      expect(m.exchange).to eql "Coinbase"
    end
  end
  