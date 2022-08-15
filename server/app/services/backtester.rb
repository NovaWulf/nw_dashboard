class Backtester < BaseService
  @asset_names
  @asset_weights
  @cursor
  @model_starttime
  @model_endtime
  @signal
  @in_sample_mean
  @multiplier
  @positions
  @prices
  @num_obs
  @num_ownable_assets
  @targets
  @orders
  @starttimes
  @model_id
  @resolution
  @log_prices
  MULTIPLIER = 2
  MAX_TRADE_SIZE_DOLLARS = 1000
  attr_accessor :model_id, :resolution, :model_starttime, :model_endtime, :in_sample_mean, :in_sample_sd, :assets,
                :asset_weights, :num_ownable_assets, :num_obs, :positions, :prices, :pnl, :targets, :version, :epoch

  def initialize(version:, epoch:)
    @version = version
    @epoch = epoch
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
    @model_id = BacktestModel.where("version=#{version} and epoch = #{epoch}").oldest_sequence_number_first.last&.model_id
    seq_num = BacktestModel.where("version=#{version} and epoch=#{epoch}").oldest_sequence_number_first.last&.sequence_number
    Rails.logger.info "backtesting model #{@model_id} with sequence number #{seq_num}"
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
    @asset_names.delete('det')
    Rails.logger.info "asset names class: #{@asset_names.class}"
    @num_ownable_assets = @asset_names.length
    modeled_signal = ModeledSignal.where("model_id = '#{@model_id}'").oldest_first
    @signal = modeled_signal.pluck(:value)
    @starttimes = modeled_signal.pluck(:starttime)
    signal_starttime = @starttimes[0]
    signal_endtime = @starttimes.last
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
    if @log_prices
      @targets = (0..(@num_ownable_assets - 1)).map do |i|
        if signal_up(@cursor)
          - @asset_weights[i] * MAX_TRADE_SIZE_DOLLARS / prices[i][@cursor]
        elsif signal_down(@cursor)
          @asset_weights[i] * MAX_TRADE_SIZE_DOLLARS / prices[i][@cursor]
        elsif @cursor > 0 && ((signal_up(@cursor) && signal_down(@cursor - 1)) || (signal_down(@cursor) && signal_up(@cursor - 1)))
          @asset_weights[i] * MAX_TRADE_SIZE_DOLLARS / prices[i][@cursor]
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
