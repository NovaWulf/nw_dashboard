module Hedgeserv
  class PositionsParser < BaseService
    attr_reader :csv_text, :row

    ISSUER_COL = 2
    MARKET_VAL_COL = 4
    DAILY_PNL_COL = 5
    MTD_PNL_COL = 6
    YTD_PNL_COL = 7
    STRATEGY_COL = 10
    DAILY_TOTAL_ROR_COL = 15
    MTD_TOTAL_ROR_COL = 16
    YTD_TOTAL_ROR_COL = 17

    def initialize(csv_text:)
      @csv_text = csv_text
    end

    def run
      rows = CSV.parse csv_text
      rows.shift # skip the header
      return ['There are no positions reported.'] if rows.blank?

      summary = rows.shift # skip the summary
      @total_daily_pnl = summary[DAILY_PNL_COL].to_i / 1000.0
      @total_mtd_pnl = summary[MTD_PNL_COL].to_i / 1000.0
      @total_ytd_pnl = summary[YTD_PNL_COL].to_i / 1000.0
      @total_daily_ror = summary[DAILY_TOTAL_ROR_COL].to_f * 100.0
      @total_mtd_ror = summary[MTD_TOTAL_ROR_COL].to_f * 100.0
      @total_ytd_ror = summary[YTD_TOTAL_ROR_COL].to_f * 100.0

      translations = [['Total',
                       format_cell(@total_daily_pnl, @total_daily_ror),
                       format_cell(@total_mtd_pnl, @total_mtd_ror),
                       format_cell(@total_ytd_pnl, @total_ytd_ror)]]

      rows.reject! { |r| (r[ISSUER_COL] || '').include?('Fee') || r[ISSUER_COL] == 'Cash' } # ignore fees and cash

      @total_market_value = sum_pnl(rows, MARKET_VAL_COL)

      Rails.logger.info "Found #{rows.count} positions"

      rows.group_by { |r| r[STRATEGY_COL].try(:titleize) }.each do |strategy, positions|
        daily_pnl = sum_pnl(positions, DAILY_PNL_COL)
        daily_cont = (daily_pnl / @total_daily_pnl) * @total_daily_ror
        mtd_pnl = sum_pnl(positions, MTD_PNL_COL)
        mtd_cont = (mtd_pnl / @total_mtd_pnl) * @total_mtd_ror
        ytd_pnl = sum_pnl(positions, YTD_PNL_COL)
        ytd_cont = (ytd_pnl / @total_ytd_pnl) * @total_ytd_ror

        market_value = sum_pnl(positions, MARKET_VAL_COL)

        str = !strategy || strategy.strip.blank? ? '[Untagged Strategy]' : strategy
        translations << ["#{str} - #{format_percent(100.0 * (market_value / @total_market_value.to_f))}",
                         format_cell(daily_pnl, daily_cont),
                         format_cell(mtd_pnl, mtd_cont),
                         format_cell(ytd_pnl, ytd_cont)]
      end

      translations
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
