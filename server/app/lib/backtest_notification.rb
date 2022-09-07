class BacktestNotification
  attr_reader :type, :basket, :signal_val, :assets, :prev_positions, :new_positions, :timestamp, :upper, :lower,
              :multiplier

  def initialize(type:, basket:, signal_val:, assets:, new_positions:, timestamp:, sd:, mean:, multiplier:)
    @type = type
    @signal_val = signal_val
    @assets = assets
    @new_positions = new_positions
    @timestamp = timestamp
    @upper = sd * multiplier + mean
    @lower = mean - sd * multiplier
    @mean = mean
    @basket = basket
  end

  def generate_subject
    "Statistical Arbitrage Indicator Alert for pair #{@basket}"
  end

  def generate_text
    if @type == 'up'
      "#{@basket} spread value (#{@signal_val.round(2)}) crossed above the high band of Paul's indicator (#{@upper.round(2)}) while position is currently at 0. Recommend buying #{@assets[1]} and shorting #{@assets[0]}. To see the chart, check out dashboard.novawulf.io/#{@basket.downcase}_arbitrage"
    elsif @type == 'down'
      "#{@basket} spread value (#{@signal_val.round(2)}) crossed above the high band of Paul's indicator (#{@lower.round(2)}) while position is currently at 0. Recommend buying #{@assets[1]} and shorting #{@assets[0]}. To see the chart, check out dashboard.novawulf.io/#{@basket.downcase}_arbitrage"
    elsif @type == 'zero'
      "#{@basket} spread value (#{@signal_val.round(2)}) crossed the mean value of Paul's indicator (#{@mean.round(2)}) while we currently have a position. Recommend closing out positions of #{@assets[1]} and #{@assets[0]}. To see the chart, check out dashboard.novawulf.io/#{@basket.downcase}_arbitrage"
    end
  end
end
