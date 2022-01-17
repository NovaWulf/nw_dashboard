class MessariDataFetcher < BaseService
  attr_reader :metric_key, :metric_display_name

  def initialize(metric_key, metric_display_name)
    @metric_key = metric_key
    @metric_display_name = metric_display_name
  end

  def run
    last_date = Metric.by_metric(metric_key).last&.timestamp
    return if last_date && last_date >= Date.today

    start_date = last_date + 1.day
    Rails.logger.info "fetching #{metric_display_name}"
    mc = Messari.new.send metric_key.to_sym, start_date
    mc_vals = mc.parsed_response['data']['values']
    Rails.logger.info "saving #{metric_display_name}"
    mc_vals.each { |m| Metric.create(timestamp: Time.at(m[0] / 1000).to_date, value: m[1], name: metric_key) }
  end
end
