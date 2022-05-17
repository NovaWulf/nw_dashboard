module Fetchers
  class EthereumSmartContractUsageFetcher < BaseService
    attr_reader :metric1, :metric2, :token

    def initialize
      @metric1 = 'smart_contract_contracts'
      @metric2 = 'smart_contract_active_users'
      @token = 'eth'
    end

    def run
      last_date = Metric.by_metric(metric1).by_token(token).last&.timestamp
      if last_date && last_date >= Date.today
        Rails.logger.info "have recent #{metric_display_name} data, returning"
        return
      end

      start_date = last_date ? last_date + 1.day : Date.new(2020, 3, 21)
      while start_date <= Date.today
        Rails.logger.info "fetching #{metric_display_name}, start date: #{start_date}"
        response = bitquery_client.eth_smart_contract_usage(day: start_date)
        return unless response

        Rails.logger.info "saving #{metric_display_name} values"
        response.each do |m|
          Metric.create(timestamp: Date.parse(m['date']['date']), value: m['contracts'], token: token,
                        metric: metric1)
          Metric.create(timestamp: Date.parse(m['date']['date']), value: m['callers'], token: token,
                        metric: metric2)
        end

        start_date = start_date.at_end_of_month + 1.day
      end
    end

    def bitquery_client
      Bitquery.new
    end

    def metric_display_name
      'Eth smart contract users and contracts'
    end
  end
end
