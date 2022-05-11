class ActiveAddressDisplayer < BaseService
  attr_reader :token

  def initialize(token:)
    @token = token
  end

  def run
    Metric.by_token(token).by_metric('active_addresses').sundays.oldest_first

    # # we group because the messari data comes in on wednesdays
    # Metric.by_token(token).by_metric('active_addresses').group_by_week(:timestamp, time_zone: false,
    #                                                                                week_start: :sunday).sum(:value).to_a.map do |m|
    #   OpenStruct.new(timestamp: m[0], value: m[1])
    # end
  end
end
