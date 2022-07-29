class CsvWriter < BaseService

  def run
    file = "#{Rails.root}/public/data.csv"
    puts "writing to csv"
    CSV.open( file, 'w' ) do |writer|
      table = Candle.all;0 # ";0" stops output.  Change "User" to any model.
      writer << table.first.attributes.map { |a,v| a }
      table.each do |s|
        writer << s.attributes.map { |a,v| v }
      end
    end
  end

end
