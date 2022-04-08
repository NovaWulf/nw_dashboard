module Hedgeserv
  class PositionsParser < BaseService
    attr_reader :csv_text, :row

    def initialize(csv_text:)
      @csv_text = csv_text
    end

    def run
      rows = CSV.parse csv_text
      rows.shift # skip the header
      rows.shift # skip the summary

      Rails.logger.info "Found #{rows.count} positions"

      if rows.blank?
        ['There are no positions reported.']
      else
        translations = []

        rows.group_by { |r| r[12] }.each do |strategy, positions|
          next if strategy == 'Cash' # skip cash

          daily_p_and_l = sum_p_and_l(positions, 7)
          monthly_p_and_l = sum_p_and_l(positions, 8)
          yearly_p_and_l = sum_p_and_l(positions, 9)
          translations << [strategy, daily_p_and_l, monthly_p_and_l, yearly_p_and_l]
        end

        translations
      end
    end

    def sum_p_and_l(positions, column)
      ActionController::Base.helpers.number_to_currency(positions.map { |p| p[column].sub(',', '').to_f }.sum(0.0))
    end
  end
end
