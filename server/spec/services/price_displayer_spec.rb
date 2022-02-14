RSpec.describe PriceDisplayer do
  subject { described_class.run(token: 'btc') }

  before(:each) do
    Metric.create(token: 'btc', metric: 'price', timestamp: Date.today, value: 1000.0)
    Metric.create(token: 'btc', metric: 'active_addresses', timestamp: Date.today, value: 500.0)
  end

  it 'returns prices' do
    expect(subject.value.count).to  eql 1
    expect(subject.value.first['value']).to eql 1000.0
  end
end
