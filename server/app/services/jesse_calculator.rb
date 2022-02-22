class JesseCalculator < BaseService
  S2F_COEFF = 0.36
  HASHRATE_COEFF = 0.00000000000000000847
  GOOGLE_TRENDS_COEFF = 209.6
  NON_ZERO_COEFF = -0.000000000000552
  Y_INTERCEPT = -360.53
  STD_ERROR = 3540

  def run
    S2fFetcher.run
    HashRateFetcher.run
    NonZeroAddressFetcher.run

    last_date = Metric.by_token('btc').by_metric('jesse').last&.timestamp
    return if last_date && last_date >= Date.today

    start_date = last_date ? last_date + 1.day : Date.new(2017, 1, 1)
    m = nil
    (start_date..Date.today).each do |day|
      s2f = Metric.by_token('btc').by_metric('s2f_ratio').by_day(day).first
      next unless s2f&.value

      hash_rate = Metric.by_token('btc').by_metric('hash_rate').by_day(day).first
      next unless hash_rate&.value

      non_zero_count = Metric.by_token('btc').by_metric('non_zero_count').by_day(day).first
      next unless non_zero_count&.value

      google_trends = Metric.by_token('btc').by_metric('google_trends').by_day(day).first
      next unless google_trends&.value

      value = s2f.value * S2F_COEFF +
              hash_rate.value * HASHRATE_COEFF +
              google_trends.value * GOOGLE_TRENDS_COEFF +
              (non_zero_count.value * non_zero_count.value) * NON_ZERO_COEFF +
              Y_INTERCEPT

      m = Metric.create(timestamp: day, value: value, token: 'btc', metric: 'jesse')
    end

    email_notification m.value if m
  end

  def email_notification(jesse_value)
    btc_price = Metric.by_token('btc').by_metric('jesse').by_day(Date.today).first

    return unless btc_price && jesse_value

    if btc_price > jesse_value + STD_ERROR
      NotificationMailer.with(subject: 'Jesse Indicator Alert',
                              text: "BTC (#{btc_price.round(2)}) is above the high band of Jesse's indicator (#{(jesse_value + STD_ERROR).round(2)}").notification.deliver_now
    elsif btc_price < jesse_value - STD_ERROR
      NotificationMailer.with(subject: 'Jesse Indicator Alert',
                              text: "BTC (#{btc_price.round(2)}) is below the low band of Jesse's indicator (#{(jesse_value - STD_ERROR).round(2)}").notification.deliver_now
    end
  end
end
