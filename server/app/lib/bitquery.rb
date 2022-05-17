class Bitquery
  API_URL = 'https://graphql.bitquery.io'
  DEFAULT_START_DATE = Date.new(2017, 1, 1)

  def initialize
    @headers = { 'Content-Type' => 'application/json',
                 "X-API-KEY": ENV['BITQUERY_TOKEN'] }
  end

  def eth_smart_contract_usage(day:)
    start_day = (day || DEFAULT_START_DATE)
    end_day = start_day.at_end_of_month

    query = '
    query ( $from: ISO8601DateTime, $till: ISO8601DateTime) {
      ethereum(network: ethereum) {
        smartContractCalls(
          date: {since: $from, till: $till}
        ) {
          date: date {
            date
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
        "from": start_day.to_date.to_s,
        "till": end_day.to_date.to_s
      }
    }.to_json
    response = run_query(body)
    response.dig('data', 'ethereum', 'smartContractCalls')
  end

  def sol_transaction_count(start_day:)
    start_day ||= Date.new(2021, 1, 1)
    end_day = start_day.at_end_of_month
    query = '
    query($startDay: ISO8601DateTime, $endDay: ISO8601DateTime){
  solana(network: solana) {
    transfers(date: {since: $startDay, till: $endDay}, transferType: {notIn: vote}) {
      date {
        date
      }
      count
    }
  }
}
'

    body = {
      query: query,
      variables: {
        "startDay": start_day.to_date.to_s,
        "endDay": end_day.to_date.to_s
      }
    }.to_json
    response = run_query(body)
    response.dig('data', 'solana', 'transfers')
  end

  def sol_active_addresses(start_day:)
    start_day ||= Date.new(2021, 1, 1)
    end_day = start_day.at_end_of_month
    query = '
     query($startDay: ISO8601DateTime, $endDay: ISO8601DateTime) {
    solana(network: solana) {
      transfers(
        date: {since: $startDay, till: $endDay}
        transferType: {notIn: vote}
      ) {
        date {
          date
        }
        count(uniq: sender_address)
      }
    }
  }
    '

    body = {
      query: query,
      variables: {
        "startDay": start_day.to_date.to_s,
        "endDay": end_day.to_date.to_s
      }
    }.to_json
    response = run_query(body)
    response.dig('data', 'solana', 'transfers')
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
