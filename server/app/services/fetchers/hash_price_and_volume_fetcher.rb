module Fetchers
  class HashPriceAndVolumeFetcher < BaseService
    def run
      last_date = Metric.by_metric('price').by_token('hash').last&.timestamp
      if last_date && last_date >= Date.today
        Rails.logger.info "have recent #{metric_display_name} data, returning"
        return
      end

      start_time = last_date ? last_date + 1.day : nil
      Rails.logger.info "fetching #{metric_display_name}, start date: #{start_time}"
      response = okcoin_client.price_and_volume(start_time: start_time)

      return unless response

      Rails.logger.info "saving #{metric_display_name}"
      response.each do |m|
        Metric.create(timestamp: m[:timestamp], value: m[:close], token: 'hash', metric: 'price')
        Metric.create(timestamp: m[:timestamp], value: m[:volume], token: 'hash', metric: 'volume')
      end
    end

    def okcoin_client
      OkCoin.new
    end

    def metric_display_name
      'HASH price and volume'
    end
  end
end
