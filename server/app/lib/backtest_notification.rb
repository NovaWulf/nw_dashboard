class BacktestNotification
  attr_reader :signal_flag, :basket, :signal_val, :assets, :prev_positions, :new_positions, :timestamp, :upper, :lower,
              :multiplier

  def initialize(signal_flag:, basket:, signal_val:, assets:, prices:, new_positions:, timestamp:, sd:, mean:, multiplier:)
    @signal_flag = signal_flag
    @signal_val = signal_val
    @assets = assets
    @prices = prices
    @new_positions = new_positions
    @timestamp = timestamp
    @upper = sd * multiplier
    @lower = - sd * multiplier
    @mean = mean
    @basket = basket
  end

  def generate_subject
    "Statistical Arbitrage Indicator Alert for pair #{@basket}"
  end

  def generate_url
    case ENV['DEPLOYMENT_NAME']
    when 'local'
      website = 'https://localhost:3001'
    when 'staging'
      website = 'https://dashboardstaging.novawulf.io'
    when 'production'
      website = 'https://dashboard.novawulf.io'
    else
      "Error: deployment has an invalid name (#{ENV['DEPLOYMENT_NAME']})"
    end
    "#{website}/#{@basket.downcase}_arbitrage"
  end

  def generate_text
    if @signal_flag == 1
      "#{@basket} spread crossed above the high band of Paul's indicator (#{@upper.round(2)} [excess return]) at #{Time.at(@timestamp).to_datetime.strftime('%c')} \r\n Prices: #{@assets[0]}: $#{@prices[0]}, #{@assets[1]}: $#{@prices[1]}. \r\n For a long exposure of $1000, buy #{@new_positions[1].round(3)} coins of #{@assets[1]} and short  #{-@new_positions[0].round(3)} of #{@assets[0]}. "
    elsif @signal_flag == -1
      "#{@basket} spread crossed below the low band of Paul's indicator (#{@lower.round(2)} [excess return])  at #{Time.at(@timestamp).to_datetime.strftime('%c')} \r\n Prices: #{@assets[0]}: $#{@prices[0]}, #{@assets[1]}: $#{@prices[1]}.\r\n For a long exposure of $1000, buy #{@new_positions[0].round(3)} coins of #{@assets[0]} and short #{-@new_positions[1].round(3)} of #{@assets[1]}. "
    elsif @signal_flag == 0
      "#{@basket} spread crossed over the mean value of Paul's indicator (#{@mean.round(2)}) [excess return])  at #{Time.at(@timestamp).to_datetime.strftime('%c')} while we had a net trading position. \r\n Prices: #{@assets[0]}: $#{@prices[0]}, #{@assets[1]}: $#{@prices[1]}.\r\n Recommend closing out positions of #{@assets[1]} and #{@assets[0]}."
    end
  end
end
