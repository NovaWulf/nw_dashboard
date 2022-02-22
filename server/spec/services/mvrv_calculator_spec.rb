RSpec.describe MvrvCalculator do
  subject { described_class.run(default_date: 2.days.ago) }
  before do
    Metric.create(token: 'btc', metric: 'circ_mcap', timestamp: Date.today, value: 2000.0)
    Metric.create(token: 'btc', metric: 'realized_mcap', timestamp: Date.today, value: 1000.0)
  end

  it 'persists' do
    subject
    expect(Metric.count).to eql 3
    m = Metric.last
    expect(m.token).to eql 'btc'
    expect(m.metric).to eql 'mvrv'
    expect(m.value).to eql 2.0
    expect(m.timestamp).to eql Date.today
  end
end
