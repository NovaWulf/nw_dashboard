RSpec.describe Displayers::CircMarketCapDisplayer do
  subject { described_class.run(token: 'btc') }

  before(:each) do
    Metric.create(token: 'btc', metric: 'price', timestamp: Date.today.prev_occurring(:sunday), value: 500.0)
    Metric.create(token: 'btc', metric: 'circ_mcap', timestamp: Date.today.prev_occurring(:sunday), value: 2000.0)
    Metric.create(token: 'btc', metric: 'active_addresses', timestamp: Date.today.prev_occurring(:sunday),
                  value: 1000.0)
  end

  it 'returns prices' do
    expect(subject.value.first['value']).to eql 2000.0
  end
end
