module Hedgeserv
  class TradeParser < BaseService
    attr_reader :csv_text, :row

    def initialize(csv_text:)
      @csv_text = csv_text
    end

    def run
      rows = CSV.parse csv_text
      rows.shift # skip the header

      Rails.logger.info "Found #{rows.count} trades"

      if rows.blank?
        ['There were no trades booked today.']
      else

        translations = []
        rows.each do |row|
          @row = row
          translations << "• #{fundname} #{trade_type} #{quantity} #{instrument_type} of #{instrument} at #{trade_price} for a total of #{cost}"
        end
        translations
      end
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
      when 'Physical'
        'tokens'
      else
        row[3]
      end
    end

    def quantity
      ActionController::Base.helpers.number_with_delimiter row[10].to_i.abs
    end

    def trade_type
      case row[9]
      when 'Buy'
        'bought'
      when 'Sell'
        'sold'
      when 'BuyCover'
        'closed the short on'
      when 'SellShort'
        'shorted'
      else
        row[9]
      end
    end

    def cost
      ActionController::Base.helpers.number_to_currency(row[22].to_f.abs)
    end

    def trade_price
      ActionController::Base.helpers.number_to_currency(row[12].to_f)
    end
  end
end
