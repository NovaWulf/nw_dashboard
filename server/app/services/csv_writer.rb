class CsvWriter < BaseService
  attr_reader :table, :assets

  DEFAULT_CSV_TABLE = 'both'
  def initialize(assets:, table: DEFAULT_CSV_TABLE)
    @table = table
    @assets = assets
  end

  def run
    if table == 'both' || table == 'candles'
      asset_string = "('" + assets.join("','") + "')"
      # add timestamp here
      file = "#{Rails.root}/public/data.csv"
      # file = "#{Rails.root}/public/data_#{Time.now.to_i}.csv"
      Rails.logger.info "writing csv to #{file}"
      CSV.open(file, 'w') do |writer|
<<<<<<< HEAD
        candles = Candle.where("pair in #{asset_string}").select(:id, :starttime, :interpolated, :close, :pair)
=======
        table = Candle.where("pair in #{asset_string}").select(:id, :starttime, :interpolated, :close, :pair)
>>>>>>> 30b2ade0264c6d964324d380fcfa1cb2fcb97c70
        0
        writer << candles.first.attributes.map { |a, _v| a }
        candles.find_each do |s|
          writer << s.attributes.map { |_a, v| v }
        end
      end
    end
    if table == 'both' || table == 'metrics'
      metric_file = "#{Rails.root}/public/metrics.csv"
      Rails.logger.info "writing csv to #{metric_file}"
      start_date = Date.new(2017, 1, 1)
      CSV.open(metric_file, 'w') do |writer|
        (start_date..Date.today).each do |day|
          ActiveRecord::Base.logger.silence do
            s2f = Metric.by_token('btc').by_metric('s2f_ratio').by_day(day).all
          end
          ActiveRecord::Base.logger.silence do
            hash_rate = Metric.by_token('btc').by_metric('hash_rate').by_day(day).all
          end
          ActiveRecord::Base.logger.silence do
            active_addresses = Metric.by_token('btc').by_metric('active_addresses').by_day(day).all
          end
          ActiveRecord::Base.logger.silence do
            google_trends = Metric.by_token('btc').by_metric('google_trends').by_day(day).all
          end
          ActiveRecord::Base.logger.silence do
            btc_price = Metric.by_token('btc').by_metric('price').by_day(day).all
          end
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
          btc_price.find_each do |s|
            writer << s.attributes.map { |_a, v| v }
          end
        end
      end
    end
    Rails.logger.info 'done writing csv'
  end
end
