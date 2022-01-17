class Messari
  include HTTParty
  base_uri 'data.messari.io/api/v1'

  DEAFULT_START_DATE = Date.new(2017,1,1)

  def initialize
    @options = { headers: { "x-messari-api-key": ENV['MESSARI_API_KEY'] } }
  end

  def btc_price(start_date = DEAFULT_START_DATE)
    self.class.get("/assets/bitcoin/metrics/price/time-series?start=#{start_date}&end=#{DateTime.now.to_date}&interval=1d",
                   @options)
  end

  def circulating_marketcap(start_date = DEAFULT_START_DATE)
    self.class.get("/assets/bitcoin/metrics/mcap-circ/time-series?start=#{start_date}&end=#{DateTime.now.to_date}&interval=1d",
                   @options)
  end

  def all_realized_marketcap(start_date = DEAFULT_START_DATE)
    self.class.get("/assets/bitcoin/metrics/mcap-realized/time-series?start=#{start_date}&end=#{DateTime.now.to_date}&interval=1d",
                   @options)
  end
end
