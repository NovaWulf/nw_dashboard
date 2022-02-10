class Messari
  include HTTParty
  base_uri 'data.messari.io/api/v1'

  DEFAULT_START_DATE = Date.new(2017, 1, 1)

  def initialize
    @options = { headers: { "x-messari-api-key": ENV['MESSARI_API_KEY'] } }
  end

  # NOTE: these names must match "#{token}_#{metric}"
  def btc_price(start_date = DEFAULT_START_DATE)
    daily_response('/assets/bitcoin/metrics/price/time-series', start_date || DEFAULT_START_DATE)
  end

  def eth_price(start_date = DEFAULT_START_DATE)
    daily_response('/assets/ethereum/metrics/price/time-series', start_date || DEFAULT_START_DATE)
  end

  def btc_circ_mcap(start_date = DEFAULT_START_DATE)
    daily_response('/assets/bitcoin/metrics/mcap-circ/time-series', start_date || DEFAULT_START_DATE)
  end

  def btc_realized_mcap(start_date = DEFAULT_START_DATE)
    daily_response('/assets/bitcoin/metrics/mcap-realized/time-series', start_date || DEFAULT_START_DATE)
  end

  def btc_active_addresses(start_date = DEFAULT_START_DATE)
    daily_response('/assets/bitcoin/metrics/act-addr-cnt/time-series', start_date || DEFAULT_START_DATE)
  end

  private

  def daily_response(path, start_date)
    response = self.class.get("#{path}?start=#{start_date}&end=#{Date.today}&interval=1d", @options)
    response.parsed_response
  end
end
