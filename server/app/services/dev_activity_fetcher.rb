class DevActivityFetcher < BaseService
  attr_reader :token

  def initialize(token:)
    @token = token
  end

  def run
    last_date = Metric.by_token(token).by_metric('dev_activity').last&.timestamp
    if last_date && last_date >= Date.today
      Rails.logger.info "have recent #{metric_display_name} data, returning"
      return
    end

    start_date = last_date ? last_date + 1.day : nil
    Rails.logger.info "fetching #{metric_display_name}, start date: #{start_date}"
    response = santiment_client.dev_activity(chain: chain_name, start_date: start_date)
    return if response.blank?

    Rails.logger.info "saving #{metric_display_name}"
    response.each do |m|
      Metric.create(timestamp: Date.parse(m['datetime']), value: m['value'], token: token, metric: 'dev_activity')
    end
  end

  def santiment_client
    Santiment.new
  end

  def chain_name
    case token
    when 'eth'
      'ethereum'
    when 'sol'
      'solana'
    when 'btc'
      'bitcoin'
    when 'luna'
      'terra'
    when 'fil'
      'file-coin'
    when 'xrp'
      'ripple'
    when 'etc'
      'ethereum-classic'
    end
  end

  def metric_display_name
    "#{token} Dev Activity"
  end
end
