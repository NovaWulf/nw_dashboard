class MvrvCalculator < BaseService
  def run
    BtcCirculatingMcapDataFetcher.run
    BtcRealizedMcapDataFetcher.run

    last_date = Metric.by_name('btc_mvrv').last&.timestamp
    return if last_date && last_date >= Date.today

    start_date = last_date ? last_date + 1.day : Date.new(2017, 1, 1)
    (start_date..Date.today).each do |day|
      mv = Metric.by_name('btc_circ_mcap').by_day(day).first
      rv = Metric.by_name('btc_realized_mcap').by_day(day).first

      if !mv || !rv
        Rails.logger.info "can't calculate mvrv for #{day}. mv present? #{mv.present?} rv present? #{rv.present?}"
        next
      end
      v = mv.value / rv.value
      Metric.create(timestamp: day, value: v, name: 'btc_mvrv')
    end
  end
end
