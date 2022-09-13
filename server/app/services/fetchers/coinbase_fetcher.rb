module Fetchers
  class CoinbaseFetcher < BaseService
    attr_reader :resolution, :pair

    def initialize(resolution:, pair:)
      @resolution = resolution
      @pair = pair
    end

    def run
      last_timestamp = Candle.by_exchange('Coinbase').by_pair(pair).by_resolution(resolution).oldest_first.last&.starttime
      Rails.logger.info "last timestamp: #{last_timestamp}"
      if last_timestamp && Time.now.to_i - last_timestamp <= resolution
        Rails.logger.info 'have recent data, returning'
        return
      end
      start_timestamp = last_timestamp ? last_timestamp + resolution : nil
      Rails.logger.info 'start timestamp: ' + start_timestamp.to_s
      response = coinbase_client.get_prices(pair: pair, start_time: start_timestamp, resolution: resolution)
      return if response.blank?

      response.each do |m|
        Candle.create(starttime: m[0], pair: pair, exchange: 'Coinbase', resolution: resolution, low: m[1], high: m[2],
                      open: m[3], close: m[4], volume: m[5])
      end
    end

    def coinbase_client
      Coinbase.new
    end
  end
end
