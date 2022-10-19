class OkCoin
  include HTTParty
  require 'openssl'
  require 'json'
  base_uri 'https://www.okcoin.com'

  DEFAULT_START_TIME = DateTime.new(2022, 5, 1, 0, 0, 0)

  def initialize
    @key = ENV['OKCOIN_API_KEY']
    @secret = ENV['OKCOIN_API_SECRET']
  end

  def price_and_volume(start_time: DEFAULT_START_TIME)
    path = '/api/spot/v3/instruments/HASH-USD/candles'
    headers = generate_headers(path)
    response = self.class.get("#{path}?start=#{(start_time || DEFAULT_START_TIME).utc.iso8601}&granularity=86400",
                              headers: headers).parsed_response
    response.map { |v| { timestamp: Date.parse(v[0]), close: v[4].to_f, volume: v[5].to_i } }
  end

  private

  def get_signature(request_path = '', timestamp = nil, method = 'GET')
    message = "#{timestamp}#{method}#{request_path}"
    # create a sha256 hmac with the secret
    secret = Base64.decode64(@secret)
    Base64.strict_encode64(OpenSSL::HMAC.hexdigest('sha256', secret, message))
  end

  def generate_headers(path)
    request_timestamp = Time.now.utc.iso8601
    {
      "OK-ACCESS-KEY": @key,
      "OK-ACCESS-SIGN": get_signature(path, request_timestamp),
      "OK-ACCESS-TIMESTAMP": request_timestamp,
      "OK-ACCESS-PASSPHRASE": @secret
    }
  end
end
