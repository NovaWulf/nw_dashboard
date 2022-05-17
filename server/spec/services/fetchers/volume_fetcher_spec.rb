RSpec.describe Fetchers::VolumeFetcher do
  subject { described_class.run(token: 'btc') }
  include_context 'messari client'

  it 'persists' do
    subject
    expect(Metric.count).to eql 1
    m = Metric.first
    expect(m.token).to eql 'btc'
    expect(m.metric).to eql 'volume'
    expect(m.value).to eql 2_000_000.0
    expect(m.timestamp).to eql Date.today
  end
end
