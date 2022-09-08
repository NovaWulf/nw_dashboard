module Hedgeserv
  class PositionsParser < BaseService
    attr_reader :csv_text, :row

    def initialize(csv_text:)
      @csv_text = csv_text
    end

    def run
      rows = CSV.parse csv_text
      rows.shift # skip the header
      if rows.blank?
        ['There are no positions reported.']
      else
        summary = rows.shift # skip the summary
        @total_daily_pnl = summary[7].to_i / 1000.0
        @total_mtd_pnl = summary[8].to_i / 1000.0
        @total_ytd_pnl = summary[9].to_i / 1000.0
        @total_daily_ror = summary[17].to_f * 100.0
        @total_mtd_ror = summary[18].to_f * 100.0
        @total_ytd_ror = summary[19].to_f * 100.0

        translations = [['Total',
                         format_cell(@total_daily_pnl, @total_daily_ror),
                         format_cell(@total_mtd_pnl, @total_mtd_ror),
                         format_cell(@total_ytd_pnl, @total_ytd_ror)]]

        rows.reject! { |r| r[2].include?('Fee') } # ignore fees

        Rails.logger.info "Found #{rows.count} positions"

        rows.group_by { |r| r[12] }.each do |strategy, positions|
          next if strategy == 'Cash' # skip cash

          daily_pnl = sum_pnl(positions, 7)
          daily_cont = (daily_pnl / @total_daily_pnl) * @total_daily_ror
          mtd_pnl = sum_pnl(positions, 8)
          mtd_cont = (mtd_pnl / @total_mtd_pnl) * @total_mtd_ror
          ytd_pnl = sum_pnl(positions, 9)
          ytd_cont = (ytd_pnl / @total_ytd_pnl) * @total_ytd_ror
          str = !strategy || strategy.strip.blank? ? '[Untagged Strategy]' : strategy
          translations << [str, format_cell(daily_pnl, daily_cont),
                           format_cell(mtd_pnl, mtd_cont),
                           format_cell(ytd_pnl, ytd_cont)]
        end

        translations
      end
    end

    def format_cell(pnl, cont)
      "#{format_currency(pnl)} [#{format_percent(cont)}]"
    end

    def ror(row, col)
      format_percent(row[col].to_f * 100.0)
    end

    def format_percent(value)
      ActionController::Base.helpers.number_to_percentage(value, precision: 1)
    end

    def sum_pnl(positions, column)
      amount = positions.map { |p| p[column].sub(',', '').to_f }.sum(0.0).to_i
      amount / 1000
    end

    def format_currency(value)
      ActionController::Base.helpers.number_to_currency(value, precision: 0, format: '%n',
                                                               negative_format: '(%n)')
    end
  end
end
