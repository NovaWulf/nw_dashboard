class Messari
  include HTTParty
  base_uri 'data.messari.io/api/v1'

  DEFAULT_START_DATE = Date.new(2017, 1, 1)

  def initialize
    @options = { headers: { "x-messari-api-key": ENV['MESSARI_API_KEY'] } }
  end

  # NOTE: these names must match "#{token}_#{metric}"
  def price(token:, start_date: DEFAULT_START_DATE)
    daily_response("/assets/#{chain_name(token)}/metrics/price/time-series", start_date || DEFAULT_START_DATE)
  end

  def circ_mcap(token:, start_date: DEFAULT_START_DATE)
    daily_response("/assets/#{chain_name(token)}/metrics/mcap-circ/time-series", start_date || DEFAULT_START_DATE)
  end

  def realized_mcap(token:, start_date: DEFAULT_START_DATE)
    daily_response("/assets/#{chain_name(token)}/metrics/mcap-realized/time-series", start_date || DEFAULT_START_DATE)
  end

  def active_addresses(token:, start_date: DEFAULT_START_DATE)
    weekly_response("/assets/#{chain_name(token)}/metrics/act-addr-cnt/time-series", start_date || DEFAULT_START_DATE)
  end

  private

  def daily_response(path, start_date)
    response(path, start_date, '1d')
  end

  def weekly_response(path, start_date)
    response(path, start_date, '1w')
  end

  def response(path, start_date, interval)
    response = self.class.get("#{path}?start=#{start_date}&end=#{Date.today}&interval=#{interval}", @options)
    response.parsed_response
  end

  def chain_name(token)
    case token
    when 'eth'
      'ethereum'
    when 'sol'
      'solana'
    when 'btc'
      'bitcoin'
    when 'luna'
      'terra'
    when 'fil'
      'file-coin'
    when 'xrp'
      'ripple'
    when 'etc'
      'ethereum-classic'
    end
  end
end
