RSpec.describe DevActivityFetcher do
  subject { described_class.run(token: 'btc') }

  let(:santiment_double) do
    double('santiment client',
           dev_activity: [{ datetime: Date.today.to_time.iso8601, value: 1000.0 }.with_indifferent_access])
  end

  before(:each) do
    allow_any_instance_of(described_class).to receive(:santiment_client).and_return(santiment_double)
  end

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
