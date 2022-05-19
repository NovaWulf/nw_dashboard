RSpec.describe JesseCalculator do
  subject { described_class.run }

  let!(:jesse_yesterday) { Metric.create(token: 'btc', metric: 'jesse', timestamp: Date.yesterday, value: 1.0).value }

  let!(:s2f) { Metric.create(token: 'btc', metric: 's2f_ratio', timestamp: Date.today, value: 1.0).value }
  let!(:hashrate) do
    Metric.create(token: 'btc', metric: 'hash_rate', timestamp: Date.today, value: 1_000_000_000_000.0).value
  end
  let!(:active_addresses_count) do
    Metric.create(token: 'btc', metric: 'active_addresses', timestamp: Date.today, value: 100_000_000.0).value
  end
  let!(:google_trends) do
    Metric.create(token: 'btc', metric: 'google_trends', timestamp: Date.today, value: 10).value
  end

  let(:jesse_intended_price) do
    s2f * JesseCalculator::S2F_COEFF +
      hashrate * JesseCalculator::HASHRATE_COEFF +
      google_trends * JesseCalculator::GOOGLE_TRENDS_COEFF +
      (active_addresses_count * active_addresses_count) * JesseCalculator::ACTIVE_ADDRESSES_COEFF +
      JesseCalculator::Y_INTERCEPT
  end

  before(:each) do
    allow_any_instance_of(described_class).to receive(:fetch_required_data).and_return(true)
  end

  it 'persists' do
    expect { subject }.to change { Metric.count }.by(1)
    m = Metric.last
    expect(m.token).to eql 'btc'
    expect(m.metric).to eql 'jesse'
    expect(m.value.round(2)).to eql jesse_intended_price.round(2)
    expect(m.timestamp).to eql Date.today
  end

  context 'btc price not in range' do
    let!(:btc_price) do
      Metric.create(token: 'btc', metric: 'price', timestamp: Date.today,
                    value: jesse_intended_price + JesseCalculator::STD_ERROR - 1)
    end

    it 'does not send email' do
      expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(0)
    end
  end

  context 'btc price in range' do
    let!(:btc_price) do
      Metric.create(token: 'btc', metric: 'price', timestamp: Date.today,
                    value: jesse_intended_price + JesseCalculator::STD_ERROR + 1)
    end

    it 'does send email' do
      expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
