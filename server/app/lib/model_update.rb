class ModelUpdate < BaseService
  attr_reader :r, :basket, :asset_names

  @r
  SECS_PER_WEEK = 604_800
  SECS_PER_HOUR = 3600
  MODEL_VERSION = 2
  MODEL_STARTDATES = ["'2022-06-13'", "'2022-06-11'", "'2022-07-12'"]
  MODEL_ENDDATES = ["'2022-07-12'", "'2022-07-27'", "'2022-08-08'"]
  def initialize(basket:)
    @r = RAdapter.new
    @basket = basket
    puts "basket: #{basket}"

    @asset_names = []
    if basket == 'OP_ETH'
      @asset_names = %w[eth-usd op-usd]
    elsif basket == 'UNI_ETH'
      @asset_names = %w[eth-usd uni-usd]
    else
      raise "not one of the registered baskets... can't create asset list"
    end
  end

  def seed
    r_count = BacktestModel.where("version = #{MODEL_VERSION} and basket = '#{basket}' and sequence_number= 0").count
    if r_count == 0
      CsvWriter.run(table: 'candles', assets: asset_names)
      return_vals = r.cointegration_analysis(asset_names: asset_names, start_time_string: MODEL_STARTDATES[0], end_time_string: MODEL_ENDDATES[0],
                                             ecdet_param: "'trend'")
      first_model = return_vals[0]
      Rails.logger.info "return val of seed model: #{return_vals}"
      Rails.logger.info "MODEL ID: #{first_model}"
      Rails.logger.info "no model detected for version #{MODEL_VERSION} seq 0... creating new seed model"
      BacktestModel.create(
        version: MODEL_VERSION,
        model_id: first_model,
        sequence_number: 0,
        name: 'seed-log',
        basket: basket
      )
    else
      model_detected = BacktestModel.where("version = #{MODEL_VERSION} and basket='#{basket}' and sequence_number= 0").last&.model_id
      Rails.logger.info "model #{model_detected} detected for sequence_number= 0... skipping creation of new seed model"
    end
  end

  def update_model(version:, max_weeks_back:, min_weeks_back:, interval_mins:, as_of_date: nil)
    as_of_time = DateTime.strptime(as_of_date, '%Y-%m-%d').to_i unless as_of_date.nil?
    ArbitrageCalculator.run(version: version, silent: true)
    Backtester.run(version: version)
    puts "as_of_time: #{as_of_time}"
    last_candle_time = as_of_time || Candle.oldest_first.last&.starttime
    sec_diff = SECS_PER_WEEK * (max_weeks_back - min_weeks_back)
    num_models = sec_diff / (60 * interval_mins) - 1
    step_size = 60 * interval_mins
    start_time = last_candle_time - SECS_PER_WEEK * max_weeks_back
    coint_models = []
    for i in 0..num_models
      start_time += step_size
      coint_models.append(@r.cointegration_analysis(asset_names: asset_names, start_time_string: start_time, end_time_string: last_candle_time,
                                                    ecdet_param: "'const'"))
      # coint_models.append(@r.cointegration_analysis(start_time_string: start_time, end_time_string: last_candle_time,
      #                                             ecdet_param: "'trend'"))
    end
    test_stats = coint_models.map { |m| m[7].to_f }
    start_times = coint_models.map { |m| m[10] }
    uuids = coint_models.map { |m| m[0] }

    max_test_stat = test_stats.max
    max_test_stat_index = test_stats.index(max_test_stat)
    max_test_stat_id = uuids[max_test_stat_index]
    best_model = CointegrationModel.where("uuid = '#{max_test_stat_id}'").last
    current_model = BacktestModel.where("version = #{version}").oldest_sequence_number_first.last
    if best_model&.test_stat > best_model&.cv_10_pct
      puts 'best new model is statistically valid with p<=.1. Auto-updating backtest models'
      puts coint_models[max_test_stat_index]
      BacktestModel.create(
        version: version,
        model_id: best_model&.uuid,
        sequence_number: current_model&.sequence_number + 1,
        name: "auto-update #{current_model&.sequence_number + 1}",
        basket: basket
      )
      ArbitrageCalculator.run(version: version, basket: basket)
      Backtester.run(version: version, basket: basket)
    end
  end

  def add_model_with_dates(version:, start_time_string:, end_time_string:)
    @r = RAdapter.new
    return_vals = @r.cointegration_analysis(asset_names: asset_names, start_time_string: start_time_string, end_time_string: end_time_string,
                                            ecdet_param: "'const'")

    new_model_id = return_vals[0]
    current_model = BacktestModel.where("version = #{version}").oldest_sequence_number_first.last
    BacktestModel.create(
      version: version,
      model_id: new_model_id,
      sequence_number: current_model&.sequence_number + 1,
      name: "manual update #{current_model&.sequence_number + 1}",
      basket: basket
    )
    ArbitrageCalculator.run(version: version, silent: true, basket: basket)
    Rails.logger.info 'arbitrage calculator complete'
    Backtester.run(version: version, basket: basket)
    Rails.logger.info 'backtester complete'
  end

  def update_jesse_model
    @r = RAdapter.new
    resulVals = @r.jesse_analysis
    JesseCalculator.run
  end
end
