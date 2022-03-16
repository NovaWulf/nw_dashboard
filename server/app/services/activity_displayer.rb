class ActivityDisplayer < BaseService
  attr_reader :token

  def initialize(token:)
    @token = token
  end

  def run
    Groupdate.week_start = :monday

    # Metric.by_token(token).by_metric('dev_activity').group_by_week(:timestamp, time_zone: false).sum(:value).to_a.map do |m|
    RepoCommit.by_token(token).group_by_week(:day, time_zone: false).sum(:count).to_a.map do |m|
      OpenStruct.new(timestamp: m[0], value: m[1])
    end
  end
end
