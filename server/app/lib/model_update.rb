class ModelUpdate < BaseService
  @r
  @RES_HOURS
  SECS_PER_WEEK = 604_800
  SECS_PER_HOUR = 3600
  def seed
    @r = RAdapter.new
    @r.cointegration_analysis(start_time_string: "'2022-06-13'", end_time_string: "'2022-07-12'",
                              ecdet_param: "'const'")
    first_model = CointegrationModel.last&.uuid
    r_count = BacktestModel.where('version= 1 and sequence_number= 0').count
    if r_count == 0
      BacktestModel.create(
        version: 1,
        model_id: first_model,
        sequence_number: 0,
        name: 'seed-log'
      )
    end
  end

  def update_model(version:, max_weeks_back:, min_weeks_back:, interval_mins:, as_of_time: nil)
    last_candle_time = as_of_time || lastCandle.oldest_first.last&.starttime
    sec_diff = SECS_PER_WEEK * (max_weeks_back - min_weeks_back)
    @r = RAdapter.new
    num_models = sec_diff / (60 * interval_mins) - 1
    step_size = 60 * interval_mins
    start_time = last_candle_time - SECS_PER_WEEK * max_weeks_back
    coint_models = []
    for i in 0..num_models
      start_time += step_size
      @r.cointegration_analysis(start_time_string: start_time, end_time_string: last_candle_time,
                                ecdet_param: "'const'")
      coint_models.append(@r.cointegration_analysis(start_time_string: start_time, end_time_string: last_candle_time,
                                                    ecdet_param: "'trend'"))
    end
    test_stats = coint_models.map { |m| m[7].to_f }
    start_times = coint_models.map { |m| m[10] }
    uuids = coint_models.map { |m| m[0] }

    max_test_stat = test_stats.max
    max_test_stat_index = test_stats.index(max_test_stat)
    max_test_stat_time = start_times[max_test_stat_index]
    max_test_stat_id = uuids[max_test_stat_index]
    best_model = CointegrationModel.where("uuid = '#{max_test_stat_id}'").last
    current_model = BacktestModel.where("version = #{version}").oldest_sequence_number_first.last
    if true
      puts 'best new model is statistically valid with p<=.1. Auto-updating backtest models'
      puts coint_models[max_test_stat_index]
      BacktestModel.create(
        version: version,
        model_id: best_model&.uuid,
        sequence_number: current_model&.sequence_number + 1,
        name: "auto-update #{current_model&.sequence_number + 1}"
      )
    end
  end
end
