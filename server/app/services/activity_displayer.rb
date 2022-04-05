class ActivityDisplayer < BaseService
  attr_reader :token

  def initialize(token:)
    @token = token
  end

  def run
    good_repo_ids = Repo.by_token(token).healthy.canonical.pluck(:id)
    RepoCommit.where(repo_id: good_repo_ids).group_by_week(:day, week_start: :sunday).sum(:count).to_a.map do |m|
      OpenStruct.new(timestamp: m[0], value: m[1])
    end
  end
end
