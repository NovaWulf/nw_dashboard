class TokenTerminal
  include HTTParty
  base_uri 'https://api.tokenterminal.com/v1/'

  DEFAULT_START_DATE = Date.new(2017, 1, 1)

  def initialize
    @options = { headers: { "Authorization": "Bearer #{ENV['TOKEN_TERMINAL_API_KEY']}" } }
  end

  def transaction_fees(token:, start_date: DEFAULT_START_DATE)
    result = daily_response("/projects/#{project(token)}/metrics")
    result.map { |r| [DateTime.parse(r['datetime']).to_date, r['revenue_protocol']] }.reverse
  end

  private

  def daily_response(path)
    JSON.parse self.class.get(path, @options).body
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
    end
  end
end
