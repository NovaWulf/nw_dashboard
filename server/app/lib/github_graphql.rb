class GithubGraphql
  API_URL = 'https://api.github.com/graphql'
  DEFAULT_START_DATE = Date.new(2017, 1, 1)

  def initialize
    @headers = { 'Content-Type' => 'application/json',
                 "Authorization": "Bearer #{ENV['GITHUB_TOKEN']}" }
  end

  def whoami
    query = '
      query {
        viewer {
          login
        }
      }
    '

    body = {
      query: query
    }.to_json

    response = run_query(body)
    response['data']['viewer']['login']
  end

  def weekly_dev_activity(repo:, day:)
    start_time = day.to_time.utc.iso8601
    end_time = (day + 1.week - 1.minute).to_time.utc.iso8601
    query = '
query ($user: String!, $name: String!, $startDate: GitTimestamp!, $endDate: GitTimestamp!) {
  repository(owner: $user, name: $name) {
    defaultBranchRef {
      target {
        ... on Commit {
          history(since: $startDate, until: $endDate) {
            totalCount
          }
        }
      }
    }
  }
}
    '

    body = {
      query: query,
      variables: { user: repo.user, name: repo.name, startDate: start_time, endDate: end_time }
    }.to_json

    response = run_query(body)
    response.dig('data', 'repository', 'defaultBranchRef', 'target', 'history', 'totalCount')
  end

  private

  def run_query(body)
    HTTParty.post(
      API_URL,
      headers: @headers,
      body: body,
      verify: false
    ).parsed_response
  end
end
