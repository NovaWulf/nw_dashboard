require 'net/sftp'

class DailyTradeProcessor < BaseService
  attr_reader :remote_filename, :csv_text, :row

  def run
    fetch_file
    return unless csv_text

    text = translate_file
    email_notification text
  end

  private

  def fetch_file
    date_string = Date.today.strftime('%Y%m%d')

    Net::SFTP.start(ENV['HS_FTP_SERVER'], ENV['HS_FTP_USER'], password: ENV['HS_FTP_PW']) do |sftp|
      sftp.dir.foreach('/Outgoing') do |entry|
        if entry.name.include?(date_string) && entry.name.include?('Transactions')
          @remote_filename = entry.name
          Rails.logger.info "Found file: #{remote_filename}"
          break
        end
      end

      if remote_filename
        sftp.file.open("Outgoing/#{remote_filename}", 'r') do |f|
          @csv_text = f.read
          puts csv_text
        end
      end
    end
  end

  def translate_file
    rows = CSV.parse @csv_text
    rows.shift # skip the header
    return nil if rows.count.zero?

    Rails.logger.info "File has #{rows.count} trades"

    translations = ["Please find today's trades below:"]
    rows.each do |row|
      @row = row
      translations << "• #{fundname} #{trade_type} #{quantity} #{instrument_type} of #{instrument} for #{cost}"
    end
    translations
  end

  def fundname
    row[1]
  end

  def instrument
    row[4]
  end

  def instrument_type
    case row[3]
    when 'Equity'
      'shares'
    when 'Option'
      'options'
    end
  end

  def quantity
    quant = row[10].to_i
    trade_type == 'shorted' ? quant * -1 : quant
  end

  def trade_type
    case row[9]
    when 'Buy'
      'bought'
    when 'SellShort'
      'shorted'
    else
      row[9]
    end
  end

  def cost
    ActionController::Base.helpers.number_to_currency row[15]
  end

  def email_notification(text)
    return unless text

    NotificationMailer.with(subject: 'Daily Trades', text: text).notification.deliver_now
  end
end
