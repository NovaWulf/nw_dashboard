RSpec.describe Fetchers::HashPriceAndVolumeFetcher do
  subject { described_class.run }
  include_context 'okcoin client'

  it 'persists' do
    subject
    expect(Metric.count).to eql 2
    m = Metric.by_token('hash').by_metric('price').first
    expect(m.value).to eql 0.0273
    expect(m.timestamp).to eql Time.now.utc.to_date

    m2 = Metric.by_token('hash').by_metric('volume').first
    expect(m2.value).to eql 9118.0
    expect(m2.timestamp).to eql Time.now.utc.to_date
  end
end
