class Messari
  include HTTParty
  base_uri 'data.messari.io/api/v1'

  DEFAULT_START_DATE = Date.new(2017, 1, 1)

  def initialize
    @options = { headers: { "x-messari-api-key": ENV['MESSARI_API_KEY'] } }
  end

  def btc_price(start_date = DEFAULT_START_DATE)
    self.class.get("/assets/bitcoin/metrics/price/time-series?start=#{start_date}&end=#{DateTime.now.to_date}&interval=1d",
                   @options)
  end

  def btc_circ_mcap(start_date = DEFAULT_START_DATE)
    self.class.get("/assets/bitcoin/metrics/mcap-circ/time-series?start=#{start_date}&end=#{DateTime.now.to_date}&interval=1d",
                   @options)
  end

  def btc_realized_mcap(start_date = DEFAULT_START_DATE)
    self.class.get("/assets/bitcoin/metrics/mcap-realized/time-series?start=#{start_date}&end=#{DateTime.now.to_date}&interval=1d",
                   @options)
  end
end
