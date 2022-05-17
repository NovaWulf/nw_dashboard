class Glassnode
  include HTTParty
  base_uri 'api.glassnode.com/v1/metrics'

  DEFAULT_START_DATE = Date.new(2017, 1, 1)

  def initialize
    @options = { headers: { "X-api-key": ENV['GLASSNODE_API_KEY'] } }
  end

  def rhodl_ratio(token:, start_date: DEFAULT_START_DATE)
    daily_response('/indicators/rhodl_ratio', token, start_date || DEFAULT_START_DATE)
  end

  def transaction_fees(token:, start_date: DEFAULT_START_DATE)
    daily_response('/fees/volume_sum?c=usd', token, start_date || DEFAULT_START_DATE)
  end

  def s2f_ratio(token:, start_date: DEFAULT_START_DATE)
    daily_response('/indicators/stock_to_flow_ratio', token, start_date || DEFAULT_START_DATE)
  end

  def hash_rate(token:, start_date: DEFAULT_START_DATE)
    daily_response('/mining/hash_rate_mean', token, start_date || DEFAULT_START_DATE)
  end

  def non_zero_count(token:, start_date: DEFAULT_START_DATE)
    daily_response('/addresses/non_zero_count', token, start_date || DEFAULT_START_DATE)
  end

  def metrics
    JSON.parse self.class.get('/endpoints', @options.merge(base_uri: 'api.glassnode.com/v2/metrics')).body
  end

  private

  def daily_response(path, token, start_date)
    JSON.parse self.class.get(
      "#{path}#{path.include?('?') ? '&' : '?'}a=#{token}&s=#{start_date.to_time.utc.to_i}&i=24h", @options
    ).body
  end
end
