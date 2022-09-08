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

        summary = rows.shift # skip the summary
        @total_daily_pnl = summary[7].to_i / 1000.0
        @total_mtd_pnl = summary[8].to_i / 1000.0
        @total_ytd_pnl = summary[9].to_i / 1000.0
        @total_daily_ror = summary[17].to_f * 100.0
        @total_mtd_ror = summary[18].to_f * 100.0
        @total_ytd_ror = summary[19].to_f * 100.0

        results = {}

        rows.reject! { |r| r[2].include?('Fee') } # ignore fees

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
      daily_rows(rows, true)
    end

    def daily_losers(rows)
      daily_rows(rows, false)
    end

    def daily_rows(rows, reverse)
      result = rows.sort_by { |r| r[7].to_f }
      result.reverse! if reverse
      result.first(3).map do |row|
        name = row[2]
        pnl = row[7].to_i / 1000
        cont_to_return = ActionController::Base.helpers.number_to_percentage(
          (pnl / @total_daily_pnl) * @total_daily_ror, precision: 1
        )
        [name, "#{pnl} [#{cont_to_return}]"]
      end
    end

    def mtd_winners(rows)
      mtd_rows(rows, true)
    end

    def mtd_losers(rows)
      mtd_rows(rows, false)
    end

    def mtd_rows(rows, reverse)
      result = rows.sort_by { |r| r[8].to_f }
      result.reverse! if reverse
      result.first(3).map do |row|
        name = row[2]
        pnl = row[8].to_i / 1000
        cont_to_return = ActionController::Base.helpers.number_to_percentage(
          (pnl / @total_mtd_pnl) * @total_mtd_ror, precision: 1
        )
        [name, "#{pnl} [#{cont_to_return}]"]
      end
    end

    def ytd_winners(rows)
      ytd_rows(rows, true)
    end

    def ytd_losers(rows)
      ytd_rows(rows, false)
    end

    def ytd_rows(rows, reverse)
      result = rows.sort_by { |r| r[9].to_f }
      result.reverse! if reverse
      result.first(3).map do |row|
        name = row[2]
        pnl = row[9].to_i / 1000
        cont_to_return = ActionController::Base.helpers.number_to_percentage(
          (pnl / @total_ytd_pnl) * @total_ytd_ror, precision: 1
        )
        [name, "#{pnl} [#{cont_to_return}]"]
      end
    end
  end
end
