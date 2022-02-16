class RhodlFetcher < BaseService
  attr_reader :token

  def initialize(token:)
    @token = token
  end

  def run
    last_date = Metric.by_token(token).by_metric('rhodl_ratio').last&.timestamp
    if last_date && last_date >= Date.today
      Rails.logger.info "have recent #{metric_display_name} data, returning"
      return
    end

    start_date = last_date ? last_date + 1.day : nil
    Rails.logger.info "fetching #{metric_display_name}, start date: #{start_date}"
    response = glassnode_client.rhodl_ratio(token: token, start_date: start_date)
    return if response.blank?

    Rails.logger.info "saving #{metric_display_name}"
    response.each do |m|
      Metric.create(timestamp: Time.at(m['t']).to_date, value: m['v'], token: token, metric: 'rhodl_ratio')
    end
  end

  def glassnode_client
    Glassnode.new
  end

  def metric_display_name
    "#{token} Rhodl Ratio"
  end
end
