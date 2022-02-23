RSpec.describe TrendsImporter do
  let(:path) do
    'https://gist.githubusercontent.com/iamnader/0bb1383cf5d4e79963597e7c3b8008a3/raw/513f2e4ac3c0260987eff0a6b220f26b243d3e3b/bitcoin_trends_test'
  end
  subject { described_class.run(path: path) }

  it 'persists' do
    subject
    expect(Metric.count).to eql 14 # 2 entries, every day of week per entry
    m = Metric.last
    expect(m.token).to eql 'btc'
    expect(m.metric).to eql 'google_trends'
    expect(m.value).to eql 5.0
    expect(m.timestamp).to eql Date.parse('2017-03-04')
  end
end
