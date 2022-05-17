class WeeklyValueDisplayer < BaseService
  attr_reader :token, :metric

  def initialize(token:, metric:)
    @token = token
    @metric = metric
  end

  def run
    Metric.by_token(token).by_metric(metric).sundays.oldest_first
  end
end
