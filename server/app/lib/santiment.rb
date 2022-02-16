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

  def dev_activity(token:, start_date: DEFAULT_START_DATE)
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

    tokens = projects(token)
    body = {
      query: query,
      variables: { tokens: tokens, startDate: (start_date || DEFAULT_START_DATE).to_time.iso8601,
                   endDate: Date.today.to_time.iso8601 }
    }.to_json

    response = run_query(body)
    response['data']['getMetric']['timeseriesData']
  end

  def projects(token)
    chain = chain_name(token)
    electric_projects = Electric.new.sub_ecosystems(chain)
    ecosystem_tokens = clean_project_names(electric_projects + [chain])
    ecosystem_tokens & all_slugs
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

  def clean_project_names(projects)
    projects.map { |s| s.downcase.gsub(' ', '-') }
  end

  def chain_name(token)
    case token
    when 'eth'
      'ethereum'
    when 'sol'
      'solana'
    when 'btc'
      'bitcoin'
    when 'luna'
      'terra'
    when 'fil'
      'file-coin'
    when 'xrp'
      'ripple'
    when 'etc'
      'ethereum-classic'
    end
  end
end
