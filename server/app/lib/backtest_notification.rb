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

  def generate_text
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
    if @signal_flag == 1
      "#{@basket} spread crossed above the high band of Paul's indicator (#{@upper.round(2)}) at #{Time.at(@timestamp).to_datetime} while trading position was at 0. \r\n Prices: #{@assets[0]}: $#{@prices[0]}, #{@assets[1]}: $#{@prices[1]}. \r\n Recommend buying (MAX_TRADE_SIZE x) #{@new_positions[1].round(3)} of #{@assets[1]} and #{@new_positions[0].round(3)} of #{@assets[0]}. To see the chart, check out #{website}/#{@basket.downcase}_arbitrage"
    elsif @signal_flag == -1
      "#{@basket} spread crossed below the low band of Paul's indicator (#{@lower.round(2)})  at #{Time.at(@timestamp).to_datetime} while trading position was at 0. \r\n Prices: #{@assets[0]}: $#{@prices[0]}, #{@assets[1]}: $#{@prices[1]}.\r\n Recommend buying (MAX_TRADE_SIZE x) #{@new_positions[0].round(3)} #{@assets[0]} and #{@new_positions[1].round(3)} of #{@assets[1]}. To see the chart, check out #{website}/#{@basket.downcase}_arbitrage"
    elsif @signal_flag == 0
      "#{@basket} spread crossed over the mean value of Paul's indicator (#{@mean.round(2)})  at #{Time.at(@timestamp).to_datetime} while we had a net trading position. \r\n Prices: #{@assets[0]}: $#{@prices[0]}, #{@assets[1]}: $#{@prices[1]}.\r\n Recommend closing out positions of #{@assets[1]} and #{@assets[0]}. To see the chart, check out #{website}/#{@basket.downcase}_arbitrage"
    end
  end
end
