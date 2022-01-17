class MvrvCalculator < BaseService
  def run
    BtcCirculatingMcapDataFetcher.run
    BtcRealizedMcapDataFetcher.run

    last_date = Metric.by_metric('btc_mvrv').last&.timestamp
    return if last_date && last_date >= Date.today

    start_date = last_date + 1.day
    (start_date..Date.today).each do |day|
      mv = Metric.by_name('btc_circ_mcap').by_day(day)
      rv = Metric.by_name('btc_realized_mcap').by_day(day)

      v = mv / rv
      Metric.create(timestamp: day, value: v, name: 'btc_mvrv')
    end
  end
end
