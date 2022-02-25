RSpec.describe MvrvCalculator do
  subject { described_class.run(default_date: 2.days.ago.to_date) }
  before do
    Metric.create(token: 'btc', metric: 'circ_mcap', timestamp: Date.today, value: 2000.0)
    Metric.create(token: 'btc', metric: 'realized_mcap', timestamp: Date.today, value: 1000.0)
  end

  before(:each) do
    allow_any_instance_of(described_class).to receive(:fetch_required_data).and_return(true)
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
