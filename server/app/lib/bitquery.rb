class Bitquery
  API_URL = 'https://graphql.bitquery.io'
  DEFAULT_START_DATE = Date.new(2017, 1, 1)

  def initialize
    @headers = { 'Content-Type' => 'application/json',
                 "X-API-KEY": ENV['BITQUERY_TOKEN'] }
  end

  def smart_contract_usage(repo:, day:)
    start_day = day.to_date.to_s
    query = '
    query ($network: EthereumNetwork!, $dateFormat: String!, $from: ISO8601DateTime, $till: ISO8601DateTime) {
      ethereum(network: $network) {
        smartContractCalls(
          options: {asc: "date.date"}
          date: {since: $from, till: $till}
        ) {
          date: date {
            date(format: $dateFormat)
          }
          contracts: countBigInt(uniq: smart_contracts)
          callers: countBigInt(uniq: senders)
        }
      }
    }
    '

    body = {
      query: query,
      variables: {
        "network": repo,
        "from": start_day,
        "till": Time.now.utc.iso8601,
        "dateFormat": '%Y-%m-%d'
      }
    }.to_json
    response = run_query(body)
    response.dig('data', repo, 'smartContractCalls')
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
