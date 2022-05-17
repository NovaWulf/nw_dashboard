module Fetchers
  class AvalancheTransactionFetcher < BaseService
    attr_reader :token, :metric

    def run
      @token = 'avax'
      @metric = 'transaction_count'

      Rails.logger.info "fetching #{metric_display_name}"
      response = snowtrace_client.transaction_count
      return if response.blank?

      Rails.logger.info "saving #{metric_display_name}"
      response.each do |m|
        Metric.where(timestamp: Date.strptime(m[0], '%D'), token: token, metric: metric).first_or_create do |metric|
          metric.value = m[2]
        end
      end
    end

    def snowtrace_client
      Snowtrace.new
    end

    def metric_display_name
      "#{token} #{metric}"
    end
  end
end
