class Backtester < BaseService
  MULTIPLIER = 2
  MAX_TRADE_SIZE_DOLLARS = 1000
  attr_reader :model_id, :resolution, :model_starttime, :model_endtime, :in_sample_mean, :in_sample_sd, :assets,
              :asset_weights, :num_ownable_assets, :num_obs, :positions, :prices, :pnl, :targets, :version, :basket, :cursor, :starttimes

  def initialize(version:, basket:)
    @version = version
    @basket = basket
  end

  def run
    @cursor = 0
    load_model(version)
    set_initial_positions
    while true
      target_positions
      generate_orders
      @cursor += 1 # time moves forward after setting target positions, before actually updating positions
      break if @cursor == @num_obs

      execute_trades
      calculate_pnl
    end
  end

  private

  def load_model(version)
    @model_id = BacktestModel.where("version=#{version} and basket = '#{basket}'").oldest_sequence_number_first.last&.model_id
    seq_num = BacktestModel.where("version=#{version} and basket='#{basket}'").oldest_sequence_number_first.last&.sequence_number
    Rails.logger.info "backtesting model #{@model_id} with sequence number #{seq_num}"
    puts "backtesting model #{@model_id} with sequence number #{seq_num}"

    model = CointegrationModel.where("uuid = '#{@model_id}'").last
    @log_prices = model&.log_prices
    @resolution = model.resolution
    @model_starttime = model.model_starttime
    @model_endtime = model.model_endtime
    @in_sample_sd = model.in_sample_sd
    @in_sample_mean = model.in_sample_mean
    weights = CointegrationModelWeight.where("uuid = '#{@model_id}'")
    assets = weights.pluck(:asset_name, :weight)
    @asset_names = assets.map { |x| x[0] }
    @asset_weights = assets.map { |x| x[1] }
    det_index = @asset_names.index('det')
    @asset_names.delete_at(det_index)
    @asset_weights.delete_at(det_index)
    @num_ownable_assets = @asset_names.length
    puts "model id in backtest: #{model_id} count: #{ModeledSignal.where("model_id = '#{@model_id}'").count}"
    modeled_signal = ModeledSignal.where("model_id = '#{@model_id}'").oldest_first.pluck(:value, :starttime)
    @signal = modeled_signal.map { |x| x[0] }
    @starttimes = modeled_signal.map { |x| x[1] }
    puts "model start time: #{@model_starttime} first time: #{@starttimes[0]}"
    start_ind = @starttimes.index(@model_starttime)
    puts "start ind: #{start_ind}"
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
    asset_weight_signs = @asset_weights.map { |a| a >= 0 ? 1 : -1 }
    if @log_prices
      @targets = (0..(@num_ownable_assets - 1)).map do |i|
        if signal_up(@cursor)
          - asset_weight_signs[i] * MAX_TRADE_SIZE_DOLLARS / prices[i][@cursor]
        elsif signal_down(@cursor)
          asset_weight_signs[i] * MAX_TRADE_SIZE_DOLLARS / prices[i][@cursor]
        elsif @cursor > 0 && ((signal_up(@cursor) && signal_down(@cursor - 1)) || (signal_down(@cursor) && signal_up(@cursor - 1)))
          asset_weight_signs[i] * MAX_TRADE_SIZE_DOLLARS / prices[i][@cursor]
        else
          @positions[i][@cursor]
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
    for i in 0..(@num_ownable_assets - 1)
      @pnl[@cursor] += @positions[i][@cursor] * (@prices[i][@cursor] - @prices[i][@cursor - 1])
      in_sample_flag = @starttimes[@cursor] <= @model_endtime
    end
    @pnl[@cursor] /= MAX_TRADE_SIZE_DOLLARS # calculate profit as a percentage of capital required
    @pnl[@cursor] += @pnl[@cursor - 1]

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

  def set_initial_positions
    return unless @cursor == 0

    @num_ownable_assets.times { |i| @positions[i][@cursor] = 0 }
  end

  def signal_up(index)
    @signal[index] > @in_sample_mean + @in_sample_sd * MULTIPLIER
  end

  def signal_down(index)
    @signal[index] < @in_sample_mean - @in_sample_sd * MULTIPLIER
  end
end
