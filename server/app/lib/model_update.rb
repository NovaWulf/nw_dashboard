class ModelUpdate < BaseService
  @r
  @RES_HOURS
  SECS_PER_WEEK = 604_800
  SECS_PER_HOUR = 3600
  def seed
    @r = RAdapter.new
    @r.cointegration_analysis(start_time_string: "'2022-07-18'", end_time_string: "'2022-08-02'",
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

  def update_model(version:, max_weeks_back:, min_weeks_back:, interval_mins:)
    last_candle_time = Candle.oldest_first.last&.starttime
    sec_diff = SECS_PER_WEEK * (max_weeks_back - min_weeks_back)
    @r = RAdapter.new
    num_models = sec_diff / (60 * interval_mins) - 1
    step_size = 60 * interval_mins
    puts "num models: #{num_models} sec diff: #{sec_diff}"
    start_time = last_candle_time - SECS_PER_WEEK * max_weeks_back
    coint_models = []
    for i in 0..num_models
      puts "i: #{i}"
      start_time += step_size
      puts "start time: #{start_time}, end time: #{last_candle_time}"
      # @r.cointegration_analysis(start_time_string: start_time, end_time_string: last_candle_time,
      #                          ecdet_param: "'const'")
      coint_models.append(@r.cointegration_analysis(start_time_string: start_time, end_time_string: last_candle_time,
                                                    ecdet_param: "'trend'"))
      puts "this coint model: #{coint_models[i]}"
    end
    test_stats = coint_models.map { |m| m[7].to_f }
    start_times = coint_models.map { |m| m[10] }
    uuids = coint_models.map { |m| m[0] }

    puts "test stats: #{test_stats}"
    max_test_stat = test_stats.max
    max_test_stat_index = test_stats.index(max_test_stat)
    max_test_stat_time = start_times[max_test_stat_index]
    max_test_stat_id = uuids[max_test_stat_index]
    puts "max test stat: #{max_test_stat}, max start time: #{max_test_stat_time}"
    best_model = CointegrationModel.where("uuid = '#{max_test_stat_id}'").last
    current_model = BacktestModel.where("version = #{version}").oldest_sequence_number_first.last
    if best_model&.test_stat > best_model&.cv_10_pct
      puts 'best new model is statistically valid with p<=.1. Auto-updating backtest models'
      BacktestModel.create(
        version: version,
        model_id: best_model&.uuid,
        sequence_number: current_model&.sequence_number + 1,
        name: "auto-update #{current_model&.sequence_number + 1}"
      )
    end
  end
end
