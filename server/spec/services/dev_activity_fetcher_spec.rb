RSpec.describe DevActivityFetcher do
  subject { described_class.run(token: 'btc') }

  include_context 'santiment client'

  it 'persists' do
    subject
    expect(Metric.count).to eql 1
    m = Metric.first
    expect(m.token).to eql 'btc'
    expect(m.metric).to eql 'dev_activity'
    expect(m.value).to eql 1_000.0
    expect(m.timestamp).to eql Date.today
  end
end
