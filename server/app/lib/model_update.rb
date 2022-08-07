class ModelUpdate < BaseService
  @r
  @RES_HOURS
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

  def update_model(version:)
    last_model = BacktestModel.by_version(version).oldest_first.last&.model_id
    last_model_time = CointegrationModel.where("uuid = '#{last_model}'").last&.model_endtime
    last_candle_time = Candle.oldest_first.last&.starttime
    @r = RAdapter.new
    num_models = (last_candle_time - last_model_time) / (3600 * @RES_HOURS) - 1
    for i in 1..num_models
      new_end_time = last_model_time + 3600 * @RES_HOURS * i
      @r.cointegration_analysis(start_time_string: last_model_time, end_time_string: new_end_time)
    end
  end

  def calc_updated_model(version:, max_months_back:, min_months_back:, res_hours:)
    last_candle_time = Candle.oldest_first.last&.starttime
    sec_diff = 2_628_000 * (max_months_back - min_months_back)
    @r = RAdapter.new
    num_models = sec_diff / (3600 * res_hours) - 1
    start_time = last_candle_time - 2_628_000 * max_months_back
    for i in 1..num_models
      start_time += i * res_hours * 3600
      puts "start time: #{start_time}, end time: #{last_candle_time}"
      @r.cointegration_analysis(start_time_string: start_time, end_time_string: last_candle_time,
                                ecdet_param: "'const'")
      @r.cointegration_analysis(start_time_string: start_time, end_time_string: last_candle_time,
                                ecdet_param: "'trend'")
    end
  end
end
