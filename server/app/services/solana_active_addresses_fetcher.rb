class SolanaActiveAddressesFetcher < BaseService
  def run
    last_date = Metric.by_metric('active_addresses').by_token('sol').last&.timestamp
    if last_date && last_date >= Date.today
      Rails.logger.info 'have recent sol active addresses data, returning'
      return
    end

    start_date = last_date ? last_date + 1.day : Date.new(2020, 3, 21)
    while start_date <= Date.today

      Rails.logger.info "fetching sol active addresses, start date: #{start_date}"
      response = bitquery_client.active_solana_addresses(start_day: start_date)
      return unless response

      Rails.logger.info 'saving sol active addresses values'
      response.each do |m|
        Metric.create(timestamp: Date.parse(m['date']['date']), value: m['count'], token: 'sol',
                      metric: 'active_addresses')
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
