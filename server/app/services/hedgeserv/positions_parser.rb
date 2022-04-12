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
        translations = [['**Total**', sum_p_and_l([summary], 7), sum_p_and_l([summary], 8), sum_p_and_l([summary], 9)]]

        Rails.logger.info "Found #{rows.count} positions"

        rows.group_by { |r| r[12] }.each do |strategy, positions|
          next if strategy == 'Cash' # skip cash

          daily_p_and_l = sum_p_and_l(positions, 7)
          monthly_p_and_l = sum_p_and_l(positions, 8)
          yearly_p_and_l = sum_p_and_l(positions, 9)
          str = !strategy || strategy.strip.blank? ? '[Untagged Strategy]' : strategy
          translations << [str, daily_p_and_l, monthly_p_and_l, yearly_p_and_l]
        end

        translations
      end
    end

    def sum_p_and_l(positions, column)
      amount = positions.map { |p| p[column].sub(',', '').to_f }.sum(0.0).to_i
      ActionController::Base.helpers.number_to_currency(amount, precision: 0)
    end
  end
end
