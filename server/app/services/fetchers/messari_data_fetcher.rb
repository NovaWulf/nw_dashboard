module Fetchers
  class MessariDataFetcher < BaseService
    attr_reader :metric, :token

    def initialize(metric:, token:)
      @metric = metric
      @token = token
    end

    def run
      last_date = Metric.by_metric(metric).by_token(token).last&.timestamp
      if last_date && last_date >= Date.today
        Rails.logger.info "have recent #{metric_display_name} data, returning"
        return
      end

      start_date = last_date ? last_date + 1.day : nil
      Rails.logger.info "fetching #{metric_display_name}, start date: #{start_date}"
      response = messari_client.send(metric.to_sym, **{ token: token, start_date: start_date })
      mc_vals = response['data']['values']
      return unless mc_vals

      Rails.logger.info "saving #{metric_display_name}"
      mc_vals.each do |m|
        Metric.create(timestamp: Time.at(m[0] / 1000).to_date, value: m[1], token: token, metric: metric)
      end
    end

    def messari_client
      Messari.new
    end

    def metric_display_name
      "#{token} #{metric}"
    end
  end
end
