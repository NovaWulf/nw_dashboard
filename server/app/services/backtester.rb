class Backtester < BaseService
  MULTIPLIER = 1
  MAX_TRADE_SIZE_DOLLARS = 1000.0
  attr_reader :model_id, :resolution, :model_starttime, :model_endtime, :in_sample_mean, :in_sample_sd, :assets, :signal_flag, :seq_num,
              :asset_weights, :num_ownable_assets, :num_obs, :positions, :prices, :pnl, :targets, :version, :basket, :cursor, :starttimes,
              :notifications, :starttimes_rollup, :prices_rollup, :pnl_last_trade, :time_last_trade, :meta_cursor, :model_name

  def initialize(version:, basket:, seq_num:, meta: true, since: '2022-10-10')
    @version = version
    @basket = basket
    @seq_num = seq_num
    @meta = meta
    @since = since
    @notifications = []
  end

  def run
    if !@meta
      @cursor = 0
      @meta_cursor = 0
      @signal_flag = nil
      load_model(version, seq_num)
      @model_name = model_id
      set_initial_positions
      while true
        target_positions
        generate_orders
        @cursor += 1 # time moves forward after setting target positions, before actually updating positions
        @meta_cursor += 1
        break if @cursor == @num_obs

        execute_trades
        calculate_pnl
      end
    else
      max_seq_num = BacktestModel.where("version=#{version} and basket='#{basket}'").oldest_sequence_number_first.last&.sequence_number
      old_positions = Array.new(2)
      old_position_drawdown = 0
      old_position_age = 0
      has_old_position = 0
      @positions = Array.new(2) { [] }
      @pnl=[]
      @pnl.append(0)
      @prices_rollup = Array.new(2) { [] }
      @starttimes_rollup = []
      @pnl_rollup 
      @meta_cursor = 0
      (0..max_seq_num).map do |seq_num|
        @cursor = 0
        @signal_flag = nil
        @next_model_endtime = nil
        early_trunc_endtime = get_model_endtime(version, seq_num + 1) if seq_num < max_seq_num
        load_model(version, seq_num, early_trunc_endtime, true)
        @model_name = "v#{version}-#{basket}-meta"
        # In the next 4 lines, were just appending in a batch here -- this could just as well be implemented with 
        # an extra append statement inside internal functions, and could also be made much more space efficient
        for i in 0..(@num_ownable_assets - 1)
          @prices_rollup[i][@prices_rollup[i].length..(@prices_rollup[i].length+@prices[i].length - 1)] = @prices[i]
        end
        @starttimes_rollup[@starttimes_rollup.length..(@starttimes_rollup.length+@starttimes.length - 1)] = @starttimes
        set_initial_positions

        while true
          target_positions
          generate_orders
          @cursor += 1 # time moves forward after setting target positions, before actually updating positions
          @meta_cursor += 1
          break if @cursor == @num_obs

          execute_trades
          calculate_pnl
        end
        # we have to pull back the meta-cursor because it gets run +1 more times compared to calculate_pnl
        @meta_cursor-=1

      end
    end

    email_notification
  end

  private

  def get_model_endtime(version, seq_num)
    @model_id = BacktestModel.where(version: version, basket: basket, sequence_number: seq_num).last&.model_id
    Rails.logger.info "backtesting model #{@model_id} with sequence number #{seq_num}"
    model = CointegrationModel.where("uuid = '#{@model_id}'").last
    model.model_endtime
  end

  def load_model(version, seq_num, early_trunc_endtime = nil, oos_only = false)
    if !seq_num
      @model_id = BacktestModel.where("version=#{version} and basket = '#{basket}'").oldest_sequence_number_first.last&.model_id
      @seq_num = BacktestModel.where("version=#{version} and basket='#{basket}'").oldest_sequence_number_first.last&.sequence_number
    else
      @model_id = BacktestModel.where(version: version, basket: basket, sequence_number: seq_num).last&.model_id
      @seq_num=seq_num
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
    if !early_trunc_endtime && oos_only == false
      modeled_signal = ModeledSignal.where("model_id = '#{@model_id}'").oldest_first.pluck(:value, :starttime)
    elsif early_trunc_endtime && oos_only == false
      modeled_signal = ModeledSignal.where("model_id = '#{@model_id}' and starttime<=#{early_trunc_endtime}").oldest_first.pluck(
        :value, :starttime
      )
    elsif !early_trunc_endtime && oos_only == true
      modeled_signal = ModeledSignal.where("model_id = '#{@model_id}' and starttime>#{@model_endtime}").oldest_first.pluck(
        :value, :starttime
      )
    else
      modeled_signal = ModeledSignal.where("model_id = '#{@model_id}' and starttime<=#{early_trunc_endtime} and starttime>#{@model_endtime}").oldest_first.pluck(
        :value, :starttime
      )
    end
    @signal = modeled_signal.map { |x| x[0] }
    @starttimes = modeled_signal.map { |x| x[1] }
    if @starttimes[0] < @model_starttime
      start_ind = @starttimes.index(@model_starttime)
      signal_starttime = @starttimes[start_ind]
      signal_endtime = @starttimes.last
      @signal = @signal[start_ind..(@signal.length - 1)]
    else
      signal_starttime = @starttimes[0]
      signal_endtime = @starttimes[@starttimes.length - 1]
    end

    @num_obs = @signal.length

    # re-initialize positions and pnl only if we're not in meta strategy
    # otherwise pnl and positions are initialize once outside the main loop
    if !@meta
      @pnl = []
      @pnl.append(0)
      @positions = Array.new(@num_ownable_assets) { [] }
    end
    
    
    @targets = Array.new(@num_ownable_assets)
    @prices = Array.new(@num_ownable_assets) { Array.new(@num_obs) }

    @prices = PriceMerger.run(asset_names: @asset_names, start_time: signal_starttime,
                              end_time: signal_endtime).value[1]
  end

  def target_positions
    # In price model, eigenvectors represent weight in shares,
    # whereas in log-price model, eigenvectors are in $

    old_signal_flag = @signal_flag
    if signal_up(@cursor) && (old_signal_flag == 0 || !old_signal_flag)
      @signal_flag = 1
      @pnl_last_trade = @pnl[@meta_cursor]
      @time_last_trade = @starttimes[@cursor]
      @targets = (0..(@num_ownable_assets - 1)).map do |i|
        #- asset_weight_signs[i] * MAX_TRADE_SIZE_DOLLARS / prices[i][@cursor]
        - asset_weights[i] * MAX_TRADE_SIZE_DOLLARS / prices[i][@cursor]
      end
    elsif signal_down(@cursor) && (old_signal_flag == 0 || !old_signal_flag)
      @signal_flag = -1
      @pnl_last_trade = @pnl[@meta_cursor]
      @time_last_trade = @starttimes[@cursor]
      @targets = (0..(@num_ownable_assets - 1)).map do |i|
        # asset_weight_signs[i] * MAX_TRADE_SIZE_DOLLARS / prices[i][@cursor]
        asset_weights[i] * MAX_TRADE_SIZE_DOLLARS / prices[i][@cursor]
      end
    elsif @cursor > 0 &&
          ((signal_pos(@cursor) && (old_signal_flag == -1 || !old_signal_flag)) ||
            (signal_neg(@cursor) && (old_signal_flag == 1 || !old_signal_flag)))
      @signal_flag = 0
      @targets = (0..(@num_ownable_assets - 1)).map do |_i|
        0
      end
    else
      @targets = (0..(@num_ownable_assets - 1)).map do |i|
        @positions[i][@meta_cursor]
      end
    end
    if old_signal_flag && @signal_flag != old_signal_flag
      r_count = BacktestTrades.where(model_id: @model_id, cursor: @cursor).count
      if r_count == 0
        BacktestTrades.create(model_id: @model_id, signal_flag: @signal_flag, prev_signal_flag: old_signal_flag,
                              cursor: @cursor, starttime: @starttimes[@cursor])
      end
    end
  end

  def generate_orders
    deltas = Array.new(@num_ownable_assets)
    for i in 0..(@num_ownable_assets - 1)
      deltas[i] = @targets[i] - @positions[i][@meta_cursor]
    end
    @orders = deltas
  end

  # NOTE: that execute_trades is happening at t+1 relative to generate_orders
  def execute_trades
    for i in 0..(@num_ownable_assets - 1)
      @positions[i].append(@positions[i][@meta_cursor - 1] + @orders[i])
      @orders[i] = 0
    end
  end

  def calculate_pnl
    this_pnl = 0
    in_sample_flag = @starttimes[@cursor] <= @model_endtime

    for i in 0..(@num_ownable_assets - 1)
      if @cursor % 1000 == 1
        r_count = ModeledSignal.where("model_id='#{@model_id}-#{@asset_names[i]}' and starttime=#{@starttimes[@cursor]}").count
        if r_count == 0
          ModeledSignal.create(
            starttime: @starttimes[@cursor],
            model_id: @model_name + '-' + @asset_names[i],
            resolution: @resolution,
            value: @targets[i] * prices[i][@cursor - 1] / MAX_TRADE_SIZE_DOLLARS,
            in_sample: in_sample_flag
          )
        end
      end
      this_pnl += @positions[i][@meta_cursor] * (@prices[i][@cursor] - @prices[i][@cursor - 1])
    end
    this_pnl /= MAX_TRADE_SIZE_DOLLARS # calculate profit as a percentage of capital required
    this_pnl += @pnl[@meta_cursor - 1]
    @pnl.append(this_pnl)
    if @cursor % 100 == 1
      r_count = ModeledSignal.where("model_id='#{@model_id}-b' and starttime=#{@starttimes[@cursor]}").count
      if r_count == 0
        ModeledSignal.create(
          starttime: @starttimes[@cursor],
          model_id: @model_name + '-b',
          resolution: @resolution,
          value: this_pnl,
          in_sample: in_sample_flag
        )
      end
    end
  end

  def set_initial_positions
    return unless @cursor == 0

    @num_ownable_assets.times { |i| @positions[i][@meta_cursor] = 0 }
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
    previous_models = BacktestModel.where("basket= '#{@basket}' and version = #{@version} and sequence_number<=#{@seq_num}").pluck(:model_id)
    # get cursor
    last_email_starttime = BacktestTrades.where(model_id: previous_models,
                                                email_sent: true).oldest_first.last&.starttime

    trades = BacktestTrades.where(model_id: @model_id).oldest_first
    most_recent_trade = trades.where("starttime>#{last_email_starttime}").last
    Rails.logger.info "last email was sent at timestep #{last_email_starttime}."
    # only send email if trade should have happened within the past day
    return unless most_recent_trade

    if most_recent_trade.starttime > @model_endtime && most_recent_trade.starttime > (Date.today - 5).to_time.to_i && Date.today.to_time.to_i - @model_endtime < 3600 * 24 * 30
      second_most_recent_trade = trades.where("starttime<#{most_recent_trade.starttime}").last
      if most_recent_trade.signal_flag == 0 && second_most_recent_trade&.starttime <= @model_endtime
        Rails.logger.info 'This is the second leg of a trade that was opened in the in-sample region. DQ: Skipping execution'
      else
        Rails.logger.info 'Sending new Email.'
        last_notif = get_notif_from_trade(most_recent_trade)
        notif_subject = last_notif.generate_subject
        notif_text = last_notif.generate_text
        notif_url = last_notif.generate_url
        Rails.logger.info "sending arb email with text: #{notif_text}"
        NotificationMailer.with(subject: notif_subject, text: notif_text, url: notif_url,
                                to_address: 'dev@novawulf.io').notification.deliver_now
        most_recent_trade.update(email_time: Time.now.to_i, email_sent: true)
      end
    end
  end

  def get_notif_from_trade(trade)
    backtest_model = BacktestModel.where(model_id: trade&.model_id)
    old_positions = (0..(@num_ownable_assets - 1)).map do |i|
      positions[i][trade&.cursor]
    end
    price_strings = @prices.map { |p| p[trade&.cursor].to_s }
    BacktestNotification.new(signal_flag: trade&.signal_flag, basket: @basket, timestamp: @starttimes[trade&.cursor], signal_val: @signal[trade&.cursor], assets: @asset_names,
                             prices: price_strings, new_positions: @targets, sd: @in_sample_sd, mean: @in_sample_mean, multiplier: MULTIPLIER)
  end
end
