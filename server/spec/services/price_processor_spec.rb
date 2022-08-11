RSpec.describe PriceMerger do
  subject { described_class.run(%w[eth-usd op-usd]) }
  before do
    Candle.create(starttime: 10_000_000,
                  pair: 'eth-usd',
                  exchange: 'Coinbase',
                  resolution: 60,
                  low: 1, high: 1, open: 1, close: 1, volume: 1)

    Candle.create(starttime: 10_000_000,
                  pair: 'op-usd',
                  exchange: 'Coinbase',
                  resolution: 60,
                  low: 2, high: 2, open: 2, close: 2, volume: 2)
  end

  it 'inner join works' do
    result = subject.value
    expect(result.length).to eql 2
    expect(result[0][0]).to eql 10_000_000
    expect(result[1][0][0]).to eql 1.0
    expect(result[1][1][0]).to eql 2.0
  end
end
