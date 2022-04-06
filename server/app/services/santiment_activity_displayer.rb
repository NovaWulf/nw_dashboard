class SantimentActivityDisplayer < BaseService
  attr_reader :token

  def initialize(token:)
    @token = token
  end

  def run
    Metric.by_token(token).by_metric('dev_activity').group_by_week(:timestamp,
                                                                   time_zone: false).sum(:value).to_a.map do |m|
      OpenStruct.new(timestamp: m[0], value: m[1])
    end
  end
end
