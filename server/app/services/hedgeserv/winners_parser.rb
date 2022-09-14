module Hedgeserv
  class WinnersParser < BaseService
    attr_reader :csv_text, :row

    ISSUER_COL = 2
    MARKET_VAL_COL = 5
    DAILY_PNL_COL = 6
    MTD_PNL_COL = 7
    YTD_PNL_COL = 8
    DAILY_TOTAL_ROR_COL = 16
    MTD_TOTAL_ROR_COL = 17
    YTD_TOTAL_ROR_COL = 18

    NUM_WINNERS = 3

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
        @total_daily_pnl = summary[DAILY_PNL_COL].to_i / 1000.0
        @total_mtd_pnl = summary[MTD_PNL_COL].to_i / 1000.0
        @total_ytd_pnl = summary[YTD_PNL_COL].to_i / 1000.0
        @total_daily_ror = summary[DAILY_TOTAL_ROR_COL].to_f * 100.0
        @total_mtd_ror = summary[MTD_TOTAL_ROR_COL].to_f * 100.0
        @total_ytd_ror = summary[YTD_TOTAL_ROR_COL].to_f * 100.0

        results = {}

        rows.reject! { |r| r[ISSUER_COL].include?('Fee') || r[ISSUER_COL] == 'Cash' } # ignore fees and cash

        Rails.logger.info "Found #{rows.count} positions"

        results[:daily_winners] = daily_winners(rows)
        results[:daily_losers] = daily_losers(rows)
        results[:mtd_winners] = mtd_winners(rows)
        results[:mtd_losers] = mtd_losers(rows)
        results[:ytd_winners] = ytd_winners(rows)
        results[:ytd_losers] = ytd_losers(rows)

        results
      end
    end

    def daily_winners(rows)
      format_winners(rows, DAILY_PNL_COL, @total_daily_pnl, @total_daily_ror, true)
    end

    def daily_losers(rows)
      format_winners(rows, DAILY_PNL_COL, @total_daily_pnl, @total_daily_ror, false)
    end

    def mtd_winners(rows)
      format_winners(rows, MTD_PNL_COL, @total_mtd_pnl, @total_mtd_ror, true)
    end

    def mtd_losers(rows)
      format_winners(rows, MTD_PNL_COL, @total_mtd_pnl, @total_mtd_ror, false)
    end

    def ytd_winners(rows)
      format_winners(rows, YTD_PNL_COL, @total_ytd_pnl, @total_ytd_ror, true)
    end

    def ytd_losers(rows)
      format_winners(rows, YTD_PNL_COL, @total_ytd_pnl, @total_ytd_ror, false)
    end

    def format_winners(rows, pnl_col, total_pnl, total_ror, reverse)
      issuers = rows.group_by { |r| r[ISSUER_COL] }.map do |issuer, positions|
        [issuer, sum_pnl(positions, pnl_col)]
      end

      result = issuers.sort_by(&:last)
      result.reverse! if reverse
      result.first(NUM_WINNERS).map do |row|
        name = row.first
        pnl = row.last
        cont_to_return = ActionController::Base.helpers.number_to_percentage(
          (pnl / total_pnl) * total_ror, precision: 1
        )
        [name, "#{format_currency(pnl)} [#{cont_to_return}]"]
      end
    end

    def format_currency(value)
      ActionController::Base.helpers.number_to_currency(value, precision: 0, format: '%n',
                                                               negative_format: '(%n)')
    end

    def sum_pnl(positions, column)
      amount = positions.map { |p| p[column].sub(',', '').to_f }.sum(0.0).to_i
      amount / 1000
    end
  end
end
