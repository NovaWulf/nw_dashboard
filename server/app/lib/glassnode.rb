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

  private

  def daily_response(path, token, start_date)
    JSON.parse self.class.get("#{path}?a=#{token}&s=#{start_date.to_time.to_i}&i=24h", @options).body
  end

  # def chain_name(token)
  #   case token
  #   when 'eth'
  #     'ethereum'
  #   when 'sol'
  #     'solana'
  #   when 'btc'
  #     'bitcoin'
  #   when 'luna'
  #     'terra'
  #   when 'fil'
  #     'file-coin'
  #   when 'xrp'
  #     'ripple'
  #   when 'etc'
  #     'ethereum-classic'
  #   end
  # end
end
