class BacktestNotification
  attr_reader :signal_flag, :basket, :signal_val, :assets, :prev_positions, :new_positions, :timestamp, :upper, :lower,
              :multiplier, :old_positions

  def initialize(signal_flag:, basket:, signal_val:, assets:, old_positions:, new_positions:, timestamp:, sd:, mean:, multiplier:)
    @signal_flag = signal_flag
    @signal_val = signal_val
    @assets = assets
    @new_positions = new_positions
    @old_positions = old_positions
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
    if @signal_flag == 1
      "#{@basket} spread crossed above the high band of Paul's indicator (#{@upper.round(2)}) at #{Time.at(@timestamp).to_datetime} while trading position was at 0. Recommend buying (MAX_TRADE_SIZE x) #{@new_positions[1].round(3)} of #{@assets[1]} and #{@new_positions[0].round(3)} of #{@assets[0]}. To see the chart, check out dashboard.novawulf.io/#{@basket.downcase}_arbitrage"
    elsif @signal_flag == -1
      "#{@basket} spread crossed below the low band of Paul's indicator (#{@lower.round(2)})  at #{Time.at(@timestamp).to_datetime} while trading position was at 0. Recommend buying (MAX_TRADE_SIZE x) #{@new_positions[0].round(3)} #{@assets[0]} and #{@new_positions[1].round(3)} of #{@assets[1]}. To see the chart, check out dashboard.novawulf.io/#{@basket.downcase}_arbitrage"
    elsif @signal_flag == 0
      "#{@basket} spread crossed over the mean value of Paul's indicator (#{@mean.round(2)})  at #{Time.at(@timestamp).to_datetime} while we had a net trading position. Recommend closing out positions of #{@assets[1]} and #{@assets[0]}. To see the chart, check out dashboard.novawulf.io/#{@basket.downcase}_arbitrage"
    end
  end
end
