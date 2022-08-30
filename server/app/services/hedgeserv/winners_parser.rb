module Hedgeserv
  class WinnersParser < BaseService
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
        rows.shift # skip the summary
        results = {}

        rows.reject { |r| r[2].include?('Fee') } # ignore fees

        Rails.logger.info "Found #{rows.count} positions"

        results[:daily_winners] = get_rows(rows, 7, 17, false)
        results[:daily_losers] = get_rows(rows, 7, 17, true)
        results[:mtd_winners] = get_rows(rows, 8, 18, false)
        results[:mtd_losers] = get_rows(rows, 8, 18, true)
        results[:ytd_winners] = get_rows(rows, 9, 19, false)
        results[:ytd_losers] = get_rows(rows, 9, 19, true)

        results
      end
    end

    def get_rows(rows, col, ror_col, losers_first)
      result = rows.sort_by { |r| r[col].to_f }
      result = result.reverse unless losers_first
      result.first(3).map { |row| format_row(row, col, ror_col) }
    end

    def format_row(row, pnl_col, ror_col)
      name = row[2]
      pnl = pnl(row, pnl_col)
      ror = ror(row, ror_col)
      [name, "#{pnl} [#{ror}]"]
    end

    def pnl(row, col)
      ActionController::Base.helpers.number_to_currency(row[col], precision: 0, format: '%u%n',
                                                                  negative_format: '(%u%n)')
    end

    def ror(row, col)
      ActionController::Base.helpers.number_to_percentage(row[col].to_f * 100.0, precision: 2)
    end
  end
end
