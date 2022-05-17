RSpec.describe Fetchers::TransactionFeeTokenTerminalFetcher do
  subject { described_class.run(token: 'sol') }
  include_context 'token terminal client'

  it 'persists' do
    subject
    expect(Metric.count).to eql 1
    m = Metric.first
    expect(m.token).to eql 'sol'
    expect(m.metric).to eql 'transaction_fees'
    expect(m.value).to eql 50_000.0
    expect(m.timestamp).to eql Date.today
  end
end
