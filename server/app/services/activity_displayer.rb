class ActivityDisplayer < BaseService
  attr_reader :token

  def initialize(token:)
    @token = token
  end

  def run
    RepoCommit.by_token(token).group_by_week(:day, week_start: :sunday).sum(:count).to_a.map do |m|
      OpenStruct.new(timestamp: m[0], value: m[1])
    end
  end
end
