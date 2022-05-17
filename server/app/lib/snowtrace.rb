class Snowtrace
  include HTTParty
  base_uri 'https://snowtrace.io/chart'

  def transaction_count
    daily_response('/tx?output=csv')
  end

  private

  def daily_response(path)
    csv = CSV.parse self.class.get(path).body
    csv.shift # remove header row
    csv
  end
end
