RSpec.describe BtcRealizedMcapDataFetcher do
  subject { described_class.run }
  include_context 'messari client'

  it 'persists' do
    subject
    expect(Metric.count).to eql 1
    m = Metric.first
    expect(m.token).to eql 'btc'
    expect(m.metric).to eql 'realized_mcap'
    expect(m.value).to eql 400_000.0
    expect(m.timestamp).to eql Date.today
  end
end
