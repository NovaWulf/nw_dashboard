module Fetchers
  class GithubActivityFetcher < BaseService
    attr_reader :repo

    def initialize(repo:)
      @repo = repo
    end

    def run
      Rails.logger.info "about to fetch data for #{repo.description}"
      weekly_data = github_client.commit_activity(repo: repo)
      unless weekly_data.is_a?(Array)
        Rails.logger.error "could not fetch data for #{repo.description}"
        Rails.logger.error weekly_data
        if weekly_data && weekly_data['message'] && weekly_data['message'] == 'Not Found'
          repo.update(error_fetching_at: Time.now)
        end

        return
      end

      weekly_data.each do |w|
        d = Time.at(w['week']).to_date

        rc = RepoCommit.find_or_create_by(day: d, repo: repo)
        rc.update(count: w['total']) unless rc.count == w['total']
      end
      repo.update(last_fetched_at: Time.now)
    end

    def github_client
      GithubRest.new
    end
  end
end
