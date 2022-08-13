class JesseCalculator < BaseService
  @std_error
  def run
    fetch_required_data

    last_jesse_model = JesseModel.newest_first.last&.id
    puts "last jesse model in calculator: #{last_jesse_model}"
    @std_error = JesseModel.newest_first.last&.standard_error
    puts "std error: #{@std_error}"
    puts "jesse model count: #{JesseModel.count}"

    assets = JesseModelWeight.where("jesse_models_id=#{last_jesse_model}").pluck(:weight, :metric_name)
    weights = assets.map { |x| x[0] }
    metric_names = assets.map { |x| x[1] }
    last_date = Metric.by_token('btc').by_metric('jesse').last&.timestamp
    puts "last date: #{last_date}"
    return if last_date && last_date >= Date.today

    puts "jesse model count: #{JesseModel.count}"

    start_date = last_date ? last_date + 1.day : Date.new(2017, 1, 1)
    m = nil
    s2f_ind = metric_names.index('s2f_ratio')
    hr_ind = metric_names.index('hash_rate')
    aa_ind = metric_names.index('active_addresses_sq')
    gt_ind = metric_names.index('google_trends')
    intercept_ind = metric_names.index('(Intercept)')

    s2f_coef = weights[s2f_ind]
    hr_coef = weights[hr_ind]
    aa_coef = weights[aa_ind]
    gt_coef = weights[gt_ind]
    intercept_coef = weights[intercept_ind]
    puts "jesse model count: #{JesseModel.count}"
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

      active_addresses = Metric.by_token('btc').by_metric('active_addresses').by_day(day).first
      unless active_addresses&.value
        Rails.logger.error "can't generate Jesse metric, no active_addresses for #{day}"
        next
      end

      google_trends = Metric.by_token('btc').by_metric('google_trends').by_day(day).first
      unless google_trends&.value
        Rails.logger.error "can't generate Jesse metric, no google_trends for #{day}"
        next
      end
      value = s2f.value * s2f_coef +
              hash_rate.value * hr_coef +
              google_trends.value * gt_coef +
              (active_addresses.value * active_addresses.value) * aa_coef +
              intercept_coef
      m = Metric.create(timestamp: day, value: value, token: 'btc', metric: 'jesse')
    end

    email_notification m if m
  end

  def fetch_required_data
    Fetchers::S2fFetcher.run
    Fetchers::HashRateFetcher.run
    Fetchers::ActiveAddressesFetcher.run(token: 'btc')
    TrendsImporter.run(path: 'https://gist.githubusercontent.com/iamnader/03b2da71d50c3cdeee4772ba66aeff2e/raw/bitcoin_trends')
  end

  def email_notification(jesse_metric)
    btc_price = Metric.by_token('btc').by_metric('price').by_day(jesse_metric.timestamp).first

    return unless btc_price && jesse_metric

    btc_value = btc_price.value
    jesse_value = jesse_metric.value

    if btc_value > jesse_value + @std_error
      NotificationMailer.with(subject: 'Jesse Indicator Alert',
                              text: "BTC (#{btc_value.round(2)}) is above the high band of Jesse's indicator (#{(jesse_value + @std_error).round(2)})").notification.deliver_now
    elsif btc_value < jesse_value - @std_error
      NotificationMailer.with(subject: 'Jesse Indicator Alert',
                              text: "BTC (#{btc_value.round(2)}) is below the low band of Jesse's indicator (#{(jesse_value - @std_error).round(2)})").notification.deliver_now
    end
  end
end
