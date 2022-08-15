RSpec.describe JesseCalculator do
  subject { described_class.run }

  let(:last_jesse_model) { JesseModel.newest_first.last&.id }
  let(:std_error) { JesseModel.newest_first.last&.standard_error }
  let(:assets) { JesseModelWeight.where("jesse_models_id=#{last_jesse_model}").pluck(:weight, :metric_name) }
  let(:weights) { assets.map { |x| x[0] } }
  let(:metric_names) { assets.map { |x| x[1] } }
  let(:s2f_coef) { weights[metric_names.index('s2f_ratio')] }
  let(:hr_coef) { weights[metric_names.index('hash_rate')] }
  let(:aa_coef) { weights[metric_names.index('active_addresses_sq')] }
  let(:gt_coef) { weights[metric_names.index('google_trends')] }
  let(:intercept) { weights[metric_names.index('(Intercept)')] }

  let!(:jesse_yesterday) do
    Metric.create(token: 'btc', metric: 'jesse', timestamp: Date.today.advance(days: -1), value: 1.0).value
  end

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
    s2f * s2f_coef +
      hashrate * hr_coef +
      google_trends * gt_coef +
      (active_addresses_count * active_addresses_count) * aa_coef +
      intercept
  end

  before(:each) do
    allow_any_instance_of(described_class).to receive(:fetch_required_data).and_return(true)

    JesseModel.create(
      id: 1,
      standard_error: 0.5,
      r_squared: 0.6,
      f_stat: 0.7,
      adj_r_squared: 0.8,
      model_starttime: 1_650_000_000,
      model_endtime: 1_660_000_000
    )
    JesseModelWeight.create(
      jesse_models_id: 1,
      metric_name: '(Intercept)',
      weight: 0.2
    )

    JesseModelWeight.create(
      jesse_models_id: 1,
      metric_name: 's2f_ratio',
      weight: 0.3
    )
    JesseModelWeight.create(
      jesse_models_id: 1,
      metric_name: 'active_addresses_sq',
      weight: 0.00000000000000004
    )
    JesseModelWeight.create(
      jesse_models_id: 1,
      metric_name: 'google_trends',
      weight: 0.5
    )
    JesseModelWeight.create(
      jesse_models_id: 1,
      metric_name: 'hash_rate',
      weight: 0.000000000000000006
    )
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
                    value: jesse_intended_price + std_error - 1)
    end

    it 'does not send email' do
      expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(0)
    end
  end

  context 'btc price in range' do
    let!(:btc_price) do
      Metric.create(token: 'btc', metric: 'price', timestamp: Date.today,
                    value: jesse_intended_price + std_error + 1)
    end

    it 'does send email' do
      expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
