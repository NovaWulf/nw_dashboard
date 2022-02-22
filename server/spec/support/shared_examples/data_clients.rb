RSpec.shared_context 'glassnode client' do
  let(:glassnode_double) do
    double('glassnode client',
           non_zero_count: [{ t: Time.now.to_i, v: 50_000 }.with_indifferent_access],
           rhodl_ratio: [{ t: Date.today.to_time.to_i, v: 1000.0 }.with_indifferent_access])
  end

  before(:each) do
    allow_any_instance_of(described_class).to receive(:glassnode_client).and_return(glassnode_double)
  end
end

RSpec.shared_context 'messari client' do
  let(:messari_double) do
    double('messari client',
           price: { data: { values: [[Time.now.to_i * 1000, 50_000]] } }.with_indifferent_access,
           circ_mcap: { data: { values: [[Time.now.to_i * 1000, 500_000]] } }.with_indifferent_access,
           realized_mcap: { data: { values: [[Time.now.to_i * 1000, 400_000]] } }.with_indifferent_access,
           active_addresses: { data: { values: [[Time.now.to_i * 1000, 50_000]] } }.with_indifferent_access)
  end

  before(:each) do
    allow_any_instance_of(described_class).to receive(:messari_client).and_return(messari_double)
  end
end

RSpec.shared_context 'santiment client' do
  let(:santiment_double) do
    double('santiment client',
           dev_activity: [{ datetime: Date.today.to_time.iso8601, value: 1000.0 }.with_indifferent_access])
  end

  before(:each) do
    allow_any_instance_of(described_class).to receive(:santiment_client).and_return(santiment_double)
  end
end
