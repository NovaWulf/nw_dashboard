class Messari
  include HTTParty
  base_uri 'data.messari.io/api/v1'

  def initialize
    @options = { headers: { "x-messari-api-key": ENV['MESSARI_API_KEY'] } }
  end

  def all_btc_price
    self.class.get("/assets/bitcoin/metrics/price/time-series?start=2017-01-01&end=#{DateTime.now.to_date}&interval=1d",
                   @options)
  end

  def all_circulating_marketcap
    self.class.get("/assets/bitcoin/metrics/mcap-circ/time-series?start=2017-01-01&end=#{DateTime.now.to_date}&interval=1d",
                   @options)
  end

  def all_realized_marketcap
    self.class.get("/assets/bitcoin/metrics/mcap-realized/time-series?start=2017-01-01&end=#{DateTime.now.to_date}&interval=1d",
                   @options)
  end
end
