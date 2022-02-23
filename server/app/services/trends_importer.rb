require 'csv'

class TrendsImporter < BaseService
  attr_reader :path

  def initialize(path:)
    @path = path
  end

  def run
    csv_data.each do |date, value|
      d = Date.parse(date)
      m = Metric.find_by(metric: 'google_trends', token: 'btc', timestamp: d)
      next if m

      # google data comes on sundays
      Metric.create(metric: 'google_trends', token: 'btc', timestamp: d, value: value)
      Metric.create(metric: 'google_trends', token: 'btc', timestamp: d + 1.day, value: value)
      Metric.create(metric: 'google_trends', token: 'btc', timestamp: d + 2.day, value: value)
      Metric.create(metric: 'google_trends', token: 'btc', timestamp: d + 3.day, value: value)
      Metric.create(metric: 'google_trends', token: 'btc', timestamp: d + 4.day, value: value)
      Metric.create(metric: 'google_trends', token: 'btc', timestamp: d + 5.day, value: value)
      Metric.create(metric: 'google_trends', token: 'btc', timestamp: d + 6.day, value: value)
    end
  end

  private

  def csv_data
    file_contents = open(@path) { |f| f.read }
    text = file_contents.split("(Worldwide)\n").count == 2 ? file_contents.split("(Worldwide)\n")[1] : file_contents # get rid of the headers
    CSV.parse text
  end
end
