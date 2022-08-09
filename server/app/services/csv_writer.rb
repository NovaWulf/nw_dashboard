class CsvWriter < BaseService
  def run
    file = "#{Rails.root}/public/data.csv"
    Rails.logger.info "writing csv to #{file}"
    CSV.open(file, 'w') do |writer|
      table = Candle.all
      0
      writer << table.first.attributes.map { |a, _v| a }
      table.find_each do |s|
        writer << s.attributes.map { |_a, v| v }
      end
    end
    metric_file = "#{Rails.root}/public/metrics.csv"
    Rails.logger.info "writing csv to #{metric_file}"
    puts "writing csv to #{metric_file}"
    start_date = Date.new(2022, 1, 1)
    CSV.open(metric_file, 'w') do |writer|
      (start_date..Date.today).each do |day|
        s2f = Metric.by_token('btc').by_metric('s2f_ratio').by_day(day).all
        0
        hash_rate = Metric.by_token('btc').by_metric('hash_rate').by_day(day).all
        0
        active_addresses = Metric.by_token('btc').by_metric('active_addresses').by_day(day).all
        0
        google_trends = Metric.by_token('btc').by_metric('google_trends').by_day(day).all
        0
        writer << s2f.first.attributes.map { |a, _v| a }

        s2f.find_each do |s|
          writer << s.attributes.map { |_a, v| v }
        end
        hash_rate.find_each do |s|
          writer << s.attributes.map { |_a, v| v }
        end
        active_addresses.find_each do |s|
          writer << s.attributes.map { |_a, v| v }
        end
        google_trends.find_each do |s|
          writer << s.attributes.map { |_a, v| v }
        end
      end
    end
    Rails.logger.info 'done writing csv'
  end
end
