class VolumeDisplayer < BaseService
  attr_reader :token

  def initialize(token:)
    @token = token
  end

  def run
    # Groupdate.week_start = :monday

    Metric.by_token(token).by_metric('volume').group_by_week(:timestamp, time_zone: false,
                                                                         week_start: :sunday).sum(:value).to_a.map do |m|
      OpenStruct.new(timestamp: m[0], value: m[1])
    end
  end
end
