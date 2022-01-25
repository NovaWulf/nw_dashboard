class MvrvCalculator < BaseService
  def run
    BtcCirculatingMcapDataFetcher.run
    BtcRealizedMcapDataFetcher.run

    last_date = Metric.by_name('btc_mvrv').last&.timestamp
    return if last_date && last_date >= Date.today

    start_date = last_date ? last_date + 1.day : Date.new(2017, 1, 1)
    m = nil
    (start_date..Date.today).each do |day|
      mv = Metric.by_name('btc_circ_mcap').by_day(day).first
      rv = Metric.by_name('btc_realized_mcap').by_day(day).first

      if !mv || !rv
        Rails.logger.info "can't calculate mvrv for #{day}. mv present? #{mv.present?} rv present? #{rv.present?}"
        next
      end
      v = mv.value / rv.value
      m = Metric.create(timestamp: day, value: v, name: 'btc_mvrv')
    end

    email_notification m.value if m
  end

  def email_notification(mvrv_value)
    if true # mvrv_value > 2.75
      NotificationMailer.with(subject: 'MVRV Alert',
                              text: "MVRV is above 2.75, with a value of #{mvrv_value}").notification.deliver_later
    elsif mvrv_value < 1.25
      NotificationMailer.with(subject: 'MVRV Alert',
                              text: "MVRV is below 1.25, with a value of #{mvrv_value}").notification.deliver_later
    end
  end
end
