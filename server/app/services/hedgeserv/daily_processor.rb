require 'net/sftp'

module Hedgeserv
  class DailyProcessor < BaseService
    attr_reader :csv_transactions_text, :csv_positions_text, :transaction_row, :run_date

    def initialize(run_date: Date.today)
      @run_date = run_date
    end

    def run
      Rails.logger.info 'Running Daily HS Processor'
      fetch_files
      trades_text = csv_transactions_text ? trade_parser.run(csv_text: csv_transactions_text).value : nil
      positions_text = csv_positions_text ? positions_parser.run(csv_text: csv_positions_text).value : nil

      email_notification(trades_text, positions_text)
    end

    private

    def fetch_files
      Net::SFTP.start(ENV['HS_FTP_SERVER'], ENV['HS_FTP_USER'], password: ENV['HS_FTP_PW']) do |sftp|
        @csv_transactions_text = find_file(sftp, 'Transactions')
        @csv_positions_text = find_file(sftp, 'Positions')
      end
    end

    def find_file(sftp, lookup_text)
      remote_filename = nil
      file_date_time = nil
      date_string = run_date.strftime('%Y%m%d')
      sftp.dir.foreach('/Outgoing') do |entry|
        if entry.name.include?("for_#{date_string}") && entry.name.include?(lookup_text)
          temp_filename = entry.name
          m = /.*_run_(.*)_at_(.*).csv/.match(temp_filename)

          if m.captures.length != 2
            Rails.logger.error "Could not regex match #{temp_filename}"
            next
          end

          temp_date_time = DateTime.parse("#{m.captures[0]}T#{m.captures[1]}")

          if !remote_filename
            remote_filename = temp_filename
            file_date_time = temp_date_time
          elsif temp_date_time > file_date_time
            remote_filename = temp_filename
            file_date_time = temp_date_time
          end
        end
      end
      Rails.logger.info "Found file: #{remote_filename}"

      unless remote_filename
        Rails.logger.error "Could not file a file for #{lookup_text}"
        return
      end

      sftp.file.open("Outgoing/#{remote_filename}", 'r') do |f|
        f.read
      end
    end

    def email_notification(trade_text, positions_text)
      NotificationMailer.with(subject: 'Daily Trades and P&L',
                              trades: trade_text, positions: positions_text, run_date: run_date).daily_trades.deliver_now
    end

    def trade_parser
      TradeParser
    end

    def positions_parser
      PositionsParser
    end
  end
end
