module Fetchers
  class TokenTerminalFetcher < BaseService
  attr_reader :metric, :token

  def initialize(metric:, token:)
    @metric = metric
    @token = token
  end

  def run
    Rails.logger.info "fetching #{metric_display_name}"
    response = token_terminal_client.send(metric.to_sym, **{ token: token })
    return if response.blank?

    Rails.logger.info "saving #{metric_display_name}"
    response.each do |m|
      Metric.where(timestamp: m[0], token: token, metric: metric).first_or_create do |metric|
        metric.value = m[1]
      end
    end
  end

  def token_terminal_client
    TokenTerminal.new
  end

  def metric_display_name
    "#{token} #{metric}"
  end
end
end