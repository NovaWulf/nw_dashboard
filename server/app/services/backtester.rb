class Backtester < BaseService
  MULTIPLIER = 1
  MAX_TRADE_SIZE_DOLLARS = 1000.0
  attr_reader :model_id, :resolution, :model_starttime, :model_endtime, :in_sample_mean, :in_sample_sd, :assets, :signal_flag, :seq_num,
              :asset_weights, :num_ownable_assets, :num_obs, :positions, :prices, :pnl, :targets, :version, :basket, :cursor, :starttimes,
              :notifications

  def initialize(version:, basket:, seq_num:)
    @version = version
    @basket = basket
    @seq_num = seq_num
    @notifications = []
  end

  def run
    @cursor = 0
    @signal_flag = 0
    load_model(version, seq_num)
    set_initial_positions
    while true
      target_positions
      generate_orders
      @cursor += 1 # time moves forward after setting target positions, before actually updating positions
      break if @cursor == @num_obs

      execute_trades
      calculate_pnl
    end
    email_notification
  end

  private

  def load_model(version, seq_num)
    if !seq_num
      @model_id = BacktestModel.where("version=#{version} and basket = '#{basket}'").oldest_sequence_number_first.last&.model_id
      @seq_num = BacktestModel.where("version=#{version} and basket='#{basket}'").oldest_sequence_number_first.last&.sequence_number
    else
      @model_id = BacktestModel.where(version: version, basket: basket, sequence_number: seq_num).last&.model_id
    end

    Rails.logger.info "backtesting model #{@model_id} with sequence number #{seq_num}"
    model = CointegrationModel.where("uuid = '#{@model_id}'").last
    @log_prices = model&.log_prices
    @resolution = model.resolution
    @model_starttime = model.model_starttime
    @model_endtime = model.model_endtime
    @in_sample_sd = model.in_sample_sd
    @in_sample_mean = model.in_sample_mean
    weights = CointegrationModelWeight.where("uuid = '#{@model_id}'").order_by_id
    assets = weights.pluck(:asset_name, :weight)
    @asset_names = assets.map { |x| x[0] }
    @asset_weights = assets.map { |x| x[1] }
    det_index = @asset_names.index('det')
    @asset_names.delete_at(det_index)
    @asset_weights.delete_at(det_index)
    @num_ownable_assets = @asset_names.length
    modeled_signal = ModeledSignal.where("model_id = '#{@model_id}'").oldest_first.pluck(:value, :starttime)
    @signal = modeled_signal.map { |x| x[0] }
    puts "modeled signal count: #{ModeledSignal.count}"
    puts "signal length: #{@signal.length}"
    @starttimes = modeled_signal.map { |x| x[1] }
    start_ind = @starttimes.index(@model_starttime)
    signal_starttime = @starttimes[start_ind]
    signal_endtime = @starttimes.last
    @signal = @signal[start_ind..(@signal.length - 1)]
    @num_obs = @signal.length
    @pnl = Array.new(@num_obs)
    @targets = Array.new(@num_ownable_assets)
    @pnl[0] = 0
    @transactions = Array.new(@num_obs)
    @prices = Array.new(@num_ownable_assets) { Array.new(@num_obs) }
    @positions = Array.new(@num_ownable_assets) { Array.new(@num_obs) }
    @prices =  PriceMerger.run(@asset_names, signal_starttime, signal_endtime).value[1]
  end

  def target_positions
    # In price model, eigenvectors represent weight in shares,
    # whereas in log-price model, eigenvectors are in $
    asset_weight_signs = @asset_weights.map { |a| a >= 0 ? 1.0 : -1.0 }

    old_signal_flag = @signal_flag
    puts "signal val: #{@signal[@cursor]}"
    if @log_prices
      if signal_up(@cursor) && old_signal_flag == 0
        puts 'signal up'
        @signal_flag = 1
        @targets = (0..(@num_ownable_assets - 1)).map do |i|
          #- asset_weight_signs[i] * MAX_TRADE_SIZE_DOLLARS / prices[i][@cursor]
          - asset_weights[i] * MAX_TRADE_SIZE_DOLLARS / prices[i][@cursor]
        end
      elsif signal_down(@cursor) &&  old_signal_flag == 0
        puts 'signal down'
        @signal_flag = -1
        @targets = (0..(@num_ownable_assets - 1)).map do |i|
          # asset_weight_signs[i] * MAX_TRADE_SIZE_DOLLARS / prices[i][@cursor]
          asset_weights[i] * MAX_TRADE_SIZE_DOLLARS / prices[i][@cursor]
        end
      elsif @cursor > 0 && ((signal_pos(@cursor) && old_signal_flag == -1) || (signal_neg(@cursor) && old_signal_flag == 1))
        puts 'signal crossed 0'
        @signal_flag = 0
        @targets = (0..(@num_ownable_assets - 1)).map do |_i|
          0
        end
      else
        puts 'nothing triggered'
        @targets = (0..(@num_ownable_assets - 1)).map do |i|
          @positions[i][@cursor]
        end
      end
      if @signal_flag != old_signal_flag
        r_count = BacktestTrades.where(model_id: @model_id, cursor: @cursor).count
        if r_count == 0
          BacktestTrades.create(model_id: @model_id, signal_flag: @signal_flag, prev_signal_flag: old_signal_flag,
                                cursor: @cursor)
        end
      end

    else
      n_shares_first_asset = MAX_TRADE_SIZE_DOLLARS / prices[0][@cursor]
      multiplier = n_shares_first_asset / @asset_weights[0]
      # NOTE: first asset weight should always be 0 using the urca package
      # but I'm writing it out here explicitly for clarity
      @targets = (0..(@num_ownable_assets - 1)).map do |i|
        if signal_up(@cursor)
          - @asset_weights[i] * multiplier
        elsif signal_down(@cursor)
          @asset_weights[i] * multiplier
        else
          @positions[i][@cursor]
        end
      end
    end
  end

  def generate_orders
    deltas = Array.new(@num_ownable_assets)
    for i in 0..(@num_ownable_assets - 1)
      deltas[i] = @targets[i] - @positions[i][@cursor]
    end
    @orders = deltas
  end

  def execute_trades
    for i in 0..(@num_ownable_assets - 1)
      @positions[i][@cursor] = @positions[i][@cursor - 1] + @orders[i]
      @orders[i] = 0
    end
  end

  def calculate_pnl
    @pnl[@cursor] = 0
    in_sample_flag = @starttimes[@cursor] <= @model_endtime

    for i in 0..(@num_ownable_assets - 1)
      if @cursor % 1000 == 1
        r_count = ModeledSignal.where("model_id='#{@model_id}-#{@asset_names[i]}' and starttime=#{@starttimes[@cursor]}").count
        if r_count == 0
          ModeledSignal.create(
            starttime: @starttimes[@cursor],
            model_id: @model_id + '-' + @asset_names[i],
            resolution: @resolution,
            value: @targets[i] * prices[i][@cursor - 1] / MAX_TRADE_SIZE_DOLLARS,
            in_sample: in_sample_flag
          )
        end
      end
      @pnl[@cursor] += @positions[i][@cursor] * (@prices[i][@cursor] - @prices[i][@cursor - 1])
    end
    @pnl[@cursor] /= MAX_TRADE_SIZE_DOLLARS # calculate profit as a percentage of capital required
    @pnl[@cursor] += @pnl[@cursor - 1]

    if @cursor % 100 == 1
      r_count = ModeledSignal.where("model_id='#{@model_id}-b' and starttime=#{@starttimes[@cursor]}").count
      if r_count == 0
        ModeledSignal.create(
          starttime: @starttimes[@cursor],
          model_id: @model_id + '-b',
          resolution: @resolution,
          value: @pnl[@cursor],
          in_sample: in_sample_flag
        )
      end
    end
  end

  def set_initial_positions
    return unless @cursor == 0

    @num_ownable_assets.times { |i| @positions[i][@cursor] = 0 }
  end

  def signal_up(index)
    @signal[index] > @in_sample_mean + @in_sample_sd * MULTIPLIER
  end

  def signal_pos(index)
    @signal[index] > @in_sample_mean
  end

  def signal_neg(index)
    @signal[index] < @in_sample_mean
  end

  def signal_down(index)
    @signal[index] < @in_sample_mean - @in_sample_sd * MULTIPLIER
  end

  def email_notification
    trades = BacktestTrades.where(model_id: @model_id).oldest_first
    last_email_cursor = trades.where(email_sent: true).last&.cursor || 0
    most_recent_trade = trades.where("cursor>#{last_email_cursor}").last
    Rails.logger.info "last email was sent at timestep #{last_email_cursor}. Sending new trade notif at time step #{most_recent_trade}"
    # only send email if trade should have happened within the past day
    if most_recent_trade && @starttimes[most_recent_trade&.cursor] > (Date.today - 45).to_time.to_i
      last_notif = get_notif_from_trade(most_recent_trade)
      notif_subject = last_notif.generate_subject
      notif_text = last_notif.generate_text
      Rails.logger.info "sending arb email with text: #{notif_text}"
      NotificationMailer.with(subject: notif_subject, text: notif_text).notification.deliver_now
      most_recent_trade.update(email_time: Time.now.to_i, email_sent: true)
    end
  end

  def get_notif_from_trade(trade)
    backtest_model = BacktestModel.where(model_id: trade&.model_id)
    old_positions = (0..(@num_ownable_assets - 1)).map do |i|
      positions[i][trade&.cursor]
    end
    BacktestNotification.new(signal_flag: trade&.signal_flag, basket: @basket, timestamp: @starttimes[trade&.cursor], signal_val: @signal[trade&.cursor], assets: @asset_names,
                             old_positions: old_positions, new_positions: @targets, sd: @in_sample_sd, mean: @in_sample_mean, multiplier: MULTIPLIER)
  end
end
