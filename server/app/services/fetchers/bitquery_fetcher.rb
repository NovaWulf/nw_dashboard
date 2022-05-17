module Fetchers
  class BitqueryFetcher < BaseService
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

    start_date = last_date ? last_date + 1.day : Date.new(2020, 3, 21)
    while start_date <= Date.today
      Rails.logger.info "fetching #{metric_display_name}, start date: #{start_date}"
      response = bitquery_client.send("#{token}_#{metric}".to_sym, **{ start_day: start_date })
      return unless response

      Rails.logger.info "saving #{metric_display_name} values"
      response.each do |m|
        Metric.create(timestamp: Date.parse(m['date']['date']), value: m['count'], token: token,
                      metric: metric)
      end

      start_date = start_date.at_end_of_month + 1.day
    end
  end

  def bitquery_client
    Bitquery.new
  end

  def metric_display_name
    "#{token} #{metric}"
  end
end
end