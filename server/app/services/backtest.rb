class Backtest
  @assets
  @asset_weights
  @cursor
  @model_starttime
  @model_endtime
  @signal
  @in_sample_mean
  @multiplier
  @max_trade_size_eth
  @positions
  @prices
  @num_obs
  @num_ownable_assets
  @targets
  @orders
  @starttimes
  @model_id
  @resolution
  MULTIPLIER = 1
  MAX_TRADE_SIZE_ETH = 1000
  attr_accessor :model_id, :resolution, :model_starttime, :model_endtime, :in_sample_mean, :in_sample_sd, :assets,
                :asset_weights, :num_ownable_assets, :num_obs, :positions, :prices, :pnl, :targets

  def run
    @cursor = 0
    load_model
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

  def load_model
    @model_id = BacktestModel.oldest_first.last.model_id
    model = CointegrationModel.where("uuid = '#{@model_id}'").last
    @resolution = model.resolution
    @model_starttime = model.model_starttime
    @model_endtime = model.model_endtime
    @in_sample_sd = model.in_sample_sd
    @in_sample_mean = model.in_sample_mean
    weights = CointegrationModelWeight.where("uuid = '#{@model_id}'")
    @assets = weights.pluck(:asset_name)
    @asset_weights = weights.pluck(:weight).uniq
    @assets.delete('det')
    @num_ownable_assets = @assets.length
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

    for i in 0..(@num_ownable_assets - 1)
      @prices[i] =
        Candle.where("pair = '#{@assets[i]}' and starttime >= #{signal_starttime} and starttime <= #{signal_endtime}").oldest_first.pluck(:close)
    end
  end

  def target_positions
    @targets = (0..(@num_ownable_assets - 1)).map do |i|
      if signal_up(@cursor)
        - @asset_weights[i] * MAX_TRADE_SIZE_ETH
      elsif signal_down(@cursor)
        @asset_weights[i] * MAX_TRADE_SIZE_ETH
      else
        @positions[i][@cursor]
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

    for i in 0..(@num_ownable_assets - 1)
      @positions[i][@cursor] = 0
    end
  end

  def signal_up(index)
    @signal[index] > @in_sample_mean + @in_sample_sd * MULTIPLIER
  end

  def signal_down(index)
    @signal[index] < @in_sample_mean - @in_sample_sd * MULTIPLIER
  end
end
