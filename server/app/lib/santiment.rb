class Santiment
  API_URL = 'https://api.santiment.net/graphql'
  DEFAULT_START_DATE = Date.new(2017, 1, 1)

  def initialize
    @headers = { 'Content-Type' => 'application/json',
                 "Authorization": "Apikey #{ENV['SANTIMENT_API_KEY']}" }
  end

  def all_slugs
    @all_slugs ||= begin
      query = '
    {
      getMetric(metric: "github_activity"){
        metadata{
          availableSlugs
        }
      }
    }
    '

      body = {
        query: query
      }.to_json

      response = run_query(body)
      response['data']['getMetric']['metadata']['availableSlugs']
    end
  end

  def dev_activity(chain:, start_date: DEFAULT_START_DATE)
    query = '
    query DevActivity($startDate: DateTime!, $endDate: DateTime!, $tokens: [String]!) {
        getMetric(metric: "dev_activity") {
            timeseriesData(selector: {slugs: $tokens}, from: $startDate, to: $endDate, interval: "1d") {
                datetime
                value
            }
        }
    }
    '

    tokens = projects(chain)
    body = {
      query: query,
      variables: { tokens: tokens, startDate: (start_date || DEFAULT_START_DATE).to_time.iso8601,
                   endDate: Date.today.to_time.iso8601 }
    }.to_json

    response = run_query(body)
    response['data']['getMetric']['timeseriesData']
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

  def projects(chain)
    electric_projects = Electric.new.sub_ecosystems(chain)
    ecosystem_tokens = clean_project_names(electric_projects + [chain])
    ecosystem_tokens & all_slugs
  end

  def clean_project_names(projects)
    projects.map { |s| s.downcase.gsub(' ', '-') }
  end
end
