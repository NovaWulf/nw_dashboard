class Coinbase

  include HTTParty
  require 'openssl'
  require 'json'
  base_uri 'https://api.exchange.coinbase.com/products'

  DEFAULT_START_TIME = DateTime.new(2022, 6, 1, 0, 0, 0).to_i.to_s

  def initialize
    @key = ENV['COINBASE_API_KEY']
    @secret = ENV['COINBASE_API_SECRET']
    @pass = ENV['COINBASE_PASS']
  end

  def get_prices(pair:, start_time: DEFAULT_START_TIME, resolution: 60)
    response("/#{pair}/candles", start_time || DEFAULT_START_TIME, resolution)
  end

  private

  def get_signature(request_path = '', timestamp = nil, method = 'GET')
    message = "#{timestamp}#{method}#{request_path}"
    # create a sha256 hmac with the secret
    secret = Base64.decode64(@secret)
    Base64.strict_encode64(OpenSSL::HMAC.hexdigest('sha256', secret, message))
  end

  def generate_headers(path)
    request_timestamp = Time.now.getutc.to_i.to_s
    {
      "CB-ACCESS-KEY": @key,
      "CB-ACCESS-TIMESTAMP": request_timestamp,
      "CB-ACCESS-PASSPHRASE": @pass,
      "CB-ACCESS-SIGN": get_signature(path, request_timestamp)
    }
  end

  def response(path, start_time, resolution)
    time_now = Time.now.getutc.to_i
    start_timestamp = start_time.to_i

    num_candles = (time_now - start_timestamp.to_i).div(resolution)

    if num_candles > 300
      responses = []
      new_start_time = time_now - 298 * resolution
      responses.concat self.class.get(
        "#{path}?start=#{new_start_time}&end=#{time_now}&granularity=#{resolution}", headers: generate_headers(path)
      ).parsed_response
      first_time = responses.last[0]
      new_end_time = first_time - resolution
      while new_end_time > start_timestamp
        new_start_time = new_end_time - 299 * resolution
        responses.concat self.class.get(
          "#{path}?start=#{new_start_time}&end=#{new_end_time}&granularity=#{resolution}", headers: generate_headers(path)
        )
                             .parsed_response
        new_end_time -= 300 * resolution
        new_end_time = start_timestamp if new_end_time < start_timestamp
        sleep 0.34
      end
    else
      responses = self.class.get(
        "#{path}?start=#{start_timestamp}&end=#{time_now}&granularity=#{resolution}", headers: generate_headers(path)
      )
      responses = responses.parsed_response
      # puts responses
    end
    responses
  end
end
