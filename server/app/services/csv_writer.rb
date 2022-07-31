class CsvWriter < BaseService
  BATCH_SIZE = 5000
  def run
    file = "#{Rails.root}/public/data.csv"
    Rails.logger.info "writing csv to #{file}"
    CSV.open( file, 'w' ) do |writer|
      table = Candle.all; # ";0" stops output. 
      writer << table.first.attributes.map { |a,v| a }
      table.find_each do |s|
        writer << s.attributes.map { |a,v| v }
      end
    end
    Rails.logger.info "done writing csv"
  end

end
