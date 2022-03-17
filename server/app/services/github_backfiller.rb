class GithubBackfiller < BaseService
  DEFAULT_START_DATE = Date.new(2017, 1, 1)

  def run
    r = Repo.where(backfilled_at: nil).first
    Rails.logger.info "Running Github Activity Fetcher for #{r.name}"

    day = DEFAULT_START_DATE
    while day < 1.year.ago
      count = github_client.weekly_dev_activity(repo: r, day: day)
      count ||= 0 # might return nil if something is wrong
      RepoCommit.create(day: day, count: count, repo: r) 
      day += 7.days
    end
    r.update(backfilled_at: Time.now)
  end

  def github_client
    GithubGraphql.new
  end
end
