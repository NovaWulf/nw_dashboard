class MessariDataFetcher < BaseService
  attr_reader :metric_key, :metric_display_name

  def initialize(metric_key:, metric_display_name:)
    @metric_key = metric_key
    @metric_display_name = metric_display_name
  end

  def run
    last_date = Metric.by_name(metric_key).last&.timestamp
    if last_date && last_date >= Date.today
      Rails.logger.info "have recent #{metric_display_name} data, returning"
      return
    end

    start_date = last_date ? last_date + 1.day : nil
    Rails.logger.info "fetching #{metric_display_name}, start date: #{start_date}"
    mc = Messari.new.send metric_key.to_sym, start_date
    mc_vals = mc.parsed_response['data']['values']
    if mc_vals
      Rails.logger.info "saving #{metric_display_name}"
      mc_vals.each { |m| Metric.create(timestamp: Time.at(m[0] / 1000).to_date, value: m[1], name: metric_key) }
    end
  end
end
