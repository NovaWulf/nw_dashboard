class JesseCalculator < BaseService
  S2F_COEFF = 0.36
  HASHRATE_COEFF = 0.00000000000000000847
  GOOGLE_TRENDS_COEFF = 209.6
  NON_ZERO_COEFF = -0.000000000000552
  Y_INTERCEPT = -360.53
  STD_ERROR = 3540

  def run
    fetch_required_data

    last_date = Metric.by_token('btc').by_metric('jesse').last&.timestamp
    return if last_date && last_date >= Date.today

    start_date = last_date ? last_date + 1.day : Date.new(2017, 1, 1)
    m = nil
    (start_date..Date.today).each do |day|
      s2f = Metric.by_token('btc').by_metric('s2f_ratio').by_day(day).first
      unless s2f&.value
        Rails.logger.error "can't generate Jesse metric, no s2f for #{day}"
        next
      end

      hash_rate = Metric.by_token('btc').by_metric('hash_rate').by_day(day).first
      unless hash_rate&.value
        Rails.logger.error "can't generate Jesse metric, no hash_rate for #{day}"
        next
      end

      non_zero_count = Metric.by_token('btc').by_metric('non_zero_count').by_day(day).first
      unless non_zero_count&.value
        Rails.logger.error "can't generate Jesse metric, no non_zero_count for #{day}"
        next
      end

      google_trends = Metric.by_token('btc').by_metric('google_trends').by_day(day).first
      unless google_trends&.value
        Rails.logger.error "can't generate Jesse metric, no google_trends for #{day}"
        next
      end

      value = s2f.value * S2F_COEFF +
              hash_rate.value * HASHRATE_COEFF +
              google_trends.value * GOOGLE_TRENDS_COEFF +
              (non_zero_count.value * non_zero_count.value) * NON_ZERO_COEFF +
              Y_INTERCEPT

      m = Metric.create(timestamp: day, value: value, token: 'btc', metric: 'jesse')
    end

    email_notification m if m
  end

  def fetch_required_data
    Fetchers::S2fFetcher.run
    Fetchers::HashRateFetcher.run
    Fetchers::NonZeroAddressFetcher.run
    TrendsImporter.run(path: 'https://gist.githubusercontent.com/iamnader/03b2da71d50c3cdeee4772ba66aeff2e/raw/bitcoin_trends')
  end

  def email_notification(jesse_metric)
    btc_price = Metric.by_token('btc').by_metric('price').by_day(jesse_metric.timestamp).first

    return unless btc_price && jesse_metric

    btc_value = btc_price.value
    jesse_value = jesse_metric.value

    if btc_value > jesse_value + STD_ERROR
      NotificationMailer.with(subject: 'Jesse Indicator Alert',
                              text: "BTC (#{btc_value.round(2)}) is above the high band of Jesse's indicator (#{(jesse_value + STD_ERROR).round(2)})").notification.deliver_now
    elsif btc_value < jesse_value - STD_ERROR
      NotificationMailer.with(subject: 'Jesse Indicator Alert',
                              text: "BTC (#{btc_value.round(2)}) is below the low band of Jesse's indicator (#{(jesse_value - STD_ERROR).round(2)})").notification.deliver_now
    end
  end
end
