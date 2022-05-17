class WeeklySumDisplayer < BaseService
  attr_reader :token, :metric

  def initialize(token:, metric:)
    @token = token
    @metric = metric
  end

  def run
    Metric.by_token(token).by_metric(metric).group_by_week(:timestamp, time_zone: false,
                                                                         week_start: :sunday).sum(:value).to_a.map do |m|
      OpenStruct.new(timestamp: m[0], value: m[1])
    end
  end
end
