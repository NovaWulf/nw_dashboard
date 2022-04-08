require 'net/sftp'

module Hedgeserv
  class DailyProcessor < BaseService
    attr_reader :csv_transactions_text, :csv_positions_text, :transaction_row

    def run
      fetch_file

      trades_text = trade_parser.run(csv_text: csv_transactions_text).value
      positions_text = positions_parser.run(csv_text: csv_positions_text).value

      email_notification(trades_text, positions_text)
    end

    private

    def fetch_file
      Net::SFTP.start(ENV['HS_FTP_SERVER'], ENV['HS_FTP_USER'], password: ENV['HS_FTP_PW']) do |sftp|
        @csv_transactions_text = find_file(sftp, 'Transactions')
        @csv_positions_text = find_file(sftp, 'Positions')
      end
    end

    def find_file(sftp, lookup_text)
      remote_filename = nil
      date_string = Date.yesterday.strftime('%Y%m%d')
      sftp.dir.foreach('/Outgoing') do |entry|
        if entry.name.include?(date_string) && entry.name.include?(lookup_text)
          remote_filename = entry.name
          Rails.logger.info "Found file: #{remote_filename}"
          break
        end
      end

      if remote_filename
        sftp.file.open("Outgoing/#{remote_filename}", 'r') do |f|
          text = f.read
          puts text
          text
        end
      end
    end

    def email_notification(trade_text, positions_text)
      NotificationMailer.with(subject: 'Daily Trades and P&L',
                              trades: trade_text, positions: positions_text).daily_trades.deliver_now
    end

    def trade_parser
      TradeParser
    end

    def positions_parser
      PositionsParser
    end
  end
end
