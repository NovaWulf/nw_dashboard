class TokenTerminal
  include HTTParty
  base_uri 'https://api.tokenterminal.com/v2/'

  DEFAULT_START_DATE = Date.new(2017, 1, 1)

  def initialize
    @options = { headers: { "Authorization": "Bearer #{ENV['TOKEN_TERMINAL_API_KEY']}" } }
  end

  def transaction_fees(token:, start_date: DEFAULT_START_DATE)
    result = daily_response("/projects/#{project(token)}/metrics", start_date)
    result.map { |r| [DateTime.parse(r['timestamp']).to_date, r['revenue_protocol']] }.reverse
  end

  private

  def daily_response(path, start_date)
    JSON.parse self.class.get("#{path}?since=#{start_date || DEFAULT_START_DATE}", @options).body
  end

  def project(token)
    case token
    when 'sol'
      'solana'
    when 'ada'
      'cardano'
    when 'avax'
      'avalanche'
    when 'near'
      'near-protocol'
    when 'uni'
      'uniswap'
    when 'crv'
      'curve'
    when 'aave'
      'aave'
    end
  end
end
