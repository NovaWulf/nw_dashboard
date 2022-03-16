class GithubActivityFetcher < BaseService
  def run
    Rails.logger.info "Running Github Activity Fetcher"
    repos = Repo.all
    repos.each do |r|
      last_date = r.repo_commits.last&.day
      if last_date && (last_date + 6.days) >= Date.today # do we have data from the last week?
        Rails.logger.info "have recent commit data for #{r.name}, returning"
        next
      end
      weekly_data = github_client.commit_activity(repo: r)
      next unless weekly_data.is_a?(Array)

      weekly_data.each do |w|
        d = Time.at(w['week']).to_date
        next if last_date && last_date >= d

        RepoCommit.create(day: d, count: w['total'], repo: r)
      end
    end
  end

  def github_client
    GithubRest.new
  end
end
