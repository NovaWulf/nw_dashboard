RSpec.describe GraphqlController do
  let(:metric_date) { Date.today.prev_occurring(:sunday) }
  before(:each) do
    Metric.create(token: 'btc', metric: 'price', timestamp: metric_date, value: 500.0)
  end

  describe 'without auth' do
    it 'returns auth error' do
      post '/graphql', params: { query: query }
      expect(JSON.parse(response.body)['errors'].first).to eql 'Not Authenticated'
    end
  end

  describe 'with auth' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:authenticate_request!).and_return(true)
    end

    it 'returns metrics' do
      post '/graphql', params: { query: query }
      expect(JSON.parse(response.body)['data']['tokenPrice']).to eql [{ 'ts' => metric_date.to_time.utc.to_i,
                                                                        'v' => 500.0 }]
    end
  end

  def query
    <<~GQL
      query{
        tokenPrice(token: "btc") {
          ts
          v
        }
      }
    GQL
  end
end
