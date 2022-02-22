RSpec.describe NonZeroAddressFetcher do
  subject { described_class.run }
  include_context 'glassnode client'

  it 'persists' do
    subject
    expect(Metric.count).to eql 1
    m = Metric.first
    expect(m.token).to eql 'btc'
    expect(m.metric).to eql 'non_zero_count'
    expect(m.value).to eql 50_000.0
    expect(m.timestamp).to eql Date.today
  end
end
