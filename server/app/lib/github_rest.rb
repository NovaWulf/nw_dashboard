class GithubRest
  include HTTParty
  base_uri 'api.github.com'

  DEFAULT_START_DATE = Date.new(2017, 1, 1)

  def initialize
    @options = { headers: { "Authorization": "token #{ENV['GITHUB_TOKEN']}" } }
  end

  def commit_activity(repo:)
    r = self.class.get("/repos/#{repo.user}/#{repo.name}/stats/commit_activity", @options).body
    r ? JSON.parse(r) : []
  end
end
