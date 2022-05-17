RSpec.describe Fetchers::RhodlFetcher do
  subject { described_class.run }
  include_context 'glassnode client'

  it 'persists' do
    subject
    expect(Metric.count).to eql 1
    m = Metric.first
    expect(m.token).to eql 'btc'
    expect(m.metric).to eql 'rhodl_ratio'
    expect(m.value).to eql 1_000.0
    expect(m.timestamp).to eql Date.today
  end
end
