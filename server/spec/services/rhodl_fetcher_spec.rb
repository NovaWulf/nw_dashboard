RSpec.describe RhodlFetcher do
  subject { described_class.run(token: 'btc') }

  let(:glassnode_double) do
    double('glassnode client', rhodl_ratio: [{ t: Date.today.to_time.to_i, v: 1000.0 }.with_indifferent_access])
  end

  before(:each) do
    allow_any_instance_of(described_class).to receive(:glassnode_client).and_return(glassnode_double)
  end

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
