class MvrvCalculator < BaseService
  attr_reader :default_date

  DEFAULT_DATE = Date.new(2017, 1, 1)

  def initialize(default_date: DEFAULT_DATE)
    @default_date = default_date
  end

  def run
    BtcCirculatingMcapDataFetcher.run
    BtcRealizedMcapDataFetcher.run

    last_date = Metric.by_token('btc').by_metric('mvrv').last&.timestamp
    return if last_date && last_date >= Date.today

    start_date = last_date ? last_date + 1.day : default_date
    m = nil
    (start_date..Date.today).each do |day|
      mv = Metric.by_token('btc').by_metric('circ_mcap').by_day(day).first
      rv = Metric.by_token('btc').by_metric('realized_mcap').by_day(day).first

      if !mv || !rv
        Rails.logger.info "can't calculate mvrv for #{day}. mv present? #{mv.present?} rv present? #{rv.present?}"
        next
      end
      v = mv.value / rv.value
      m = Metric.create(timestamp: day, value: v, token: 'btc', metric: 'mvrv')
    end

    email_notification m.value if m
  end

  def email_notification(mvrv_value)
    if mvrv_value > 2.75
      NotificationMailer.with(subject: 'MVRV Alert',
                              text: "MVRV is above 2.75, with a value of #{mvrv_value}").notification.deliver_now
    elsif mvrv_value < 1.25
      NotificationMailer.with(subject: 'MVRV Alert',
                              text: "MVRV is below 1.25, with a value of #{mvrv_value}").notification.deliver_now
    end
  end
end
