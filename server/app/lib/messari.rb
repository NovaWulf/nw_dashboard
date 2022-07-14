class Messari
  include HTTParty
  base_uri 'data.messari.io/api/v1'

  DEFAULT_START_DATE = Date.new(2017, 1, 10)

  def initialize
    @options = { headers: { "x-messari-api-key": ENV['MESSARI_API_KEY'] } }
  end

  def price(token:, start_date: DEFAULT_START_DATE)
    puts "start date: " + (start_date|| DEFAULT_START_DATE).to_s
    daily_response("/assets/#{slug(token)}/metrics/price/time-series", start_date || DEFAULT_START_DATE)
  end

  def volume(token:, start_date: DEFAULT_START_DATE)
    daily_response("/assets/#{slug(token)}/metrics/real-vol/time-series", start_date || DEFAULT_START_DATE)
  end

  def circ_mcap(token:, start_date: DEFAULT_START_DATE)
    daily_response("/assets/#{slug(token)}/metrics/mcap-circ/time-series", start_date || DEFAULT_START_DATE)
  end

  def fully_diluted_mcap(token:, start_date: DEFAULT_START_DATE)
    daily_response("/assets/#{slug(token)}/metrics/mcap-out/time-series", start_date || DEFAULT_START_DATE)
  end

  def transaction_count(token:, start_date: DEFAULT_START_DATE)
    daily_response("/assets/#{slug(token)}/metrics/txn-cnt/time-series", start_date || DEFAULT_START_DATE)
  end

  def circ_supply(token:, start_date: DEFAULT_START_DATE)
    daily_response("/assets/#{slug(token)}/metrics/sply-circ/time-series", start_date || DEFAULT_START_DATE)
  end

  def realized_mcap(token:, start_date: DEFAULT_START_DATE)
    daily_response("/assets/#{slug(token)}/metrics/mcap-realized/time-series", start_date || DEFAULT_START_DATE)
  end

  def mcap_dominance(token:, start_date: DEFAULT_START_DATE)
    daily_response("/assets/#{slug(token)}/metrics/mcap-dom/time-series", start_date || DEFAULT_START_DATE)
  end

  def smart_contract_txn_count(token:, start_date: DEFAULT_START_DATE)
    daily_response("/assets/#{slug(token)}/metrics/txn-cont-cnt/time-series", start_date || DEFAULT_START_DATE)
  end

  # def active_addresses(token:, start_date: DEFAULT_START_DATE)
  #   weekly_response("/assets/#{slug(token)}/metrics/act-addr-cnt/time-series", start_date || DEFAULT_START_DATE)
  # end

  def active_addresses(token:, start_date: DEFAULT_START_DATE)
    daily_response("/assets/#{slug(token)}/metrics/act-addr-cnt/time-series", start_date || DEFAULT_START_DATE)
  end

  def assets
    self.class.get('/assets?fields=symbol').parsed_response
  end

  def asset(token:)
    self.class.get("/assets/#{token}").parsed_response
  end

  def asset_metrics(token:)
    self.class.get("/assets/#{token}/metrics").parsed_response
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

  def slug(token)
    # in case we need to map
    token
  end
end
