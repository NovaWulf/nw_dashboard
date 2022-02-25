RSpec.describe JesseCalculator do
  subject { described_class.run }

  let!(:s2f) { Metric.create(token: 'btc', metric: 's2f_ratio', timestamp: Date.today, value: 1.0).value }
  let!(:hashrate) do
    Metric.create(token: 'btc', metric: 'hash_rate', timestamp: Date.today, value: 1_000_000_000_000.0).value
  end
  let!(:non_zero_count) do
    Metric.create(token: 'btc', metric: 'non_zero_count', timestamp: Date.today, value: 100_000_000.0).value
  end
  let!(:google_trends) do
    Metric.create(token: 'btc', metric: 'google_trends', timestamp: Date.today, value: 10).value
  end 

  before(:each) do
    allow_any_instance_of(described_class).to receive(:fetch_required_data).and_return(true)
  end

  it 'persists' do
    subject
    expect(Metric.count).to eql 5
    m = Metric.last
    expect(m.token).to eql 'btc'
    expect(m.metric).to eql 'jesse'
    expect(m.value.round(2)).to eql (s2f * JesseCalculator::S2F_COEFF +
                           hashrate * JesseCalculator::HASHRATE_COEFF +
                           google_trends * JesseCalculator::GOOGLE_TRENDS_COEFF +
                           (non_zero_count * non_zero_count) * JesseCalculator::NON_ZERO_COEFF +
                           JesseCalculator::Y_INTERCEPT).round(2)
    expect(m.timestamp).to eql Date.today
  end
end
