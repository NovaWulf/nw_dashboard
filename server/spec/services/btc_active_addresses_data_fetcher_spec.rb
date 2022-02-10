RSpec.describe BtcActiveAddressesFetcher do
  subject { described_class.run }

  let(:messari_double) do
    double('messari client',
           btc_active_addresses: { data: { values: [[Time.now.to_i * 1000, 50_000]] } }.with_indifferent_access)
  end

  before(:each) do
    allow_any_instance_of(described_class).to receive(:messari_client).and_return(messari_double)
  end

  it 'persists' do
    subject
    expect(Metric.count).to eql 1
    m = Metric.first
    expect(m.token).to eql 'btc'
    expect(m.metric).to eql 'active_addresses'
    expect(m.value).to eql 50_000.0
    expect(m.timestamp).to eql Date.today
  end
end
