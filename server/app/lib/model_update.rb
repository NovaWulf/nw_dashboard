class ModelUpdate < BaseService
  @r
  @RES_HOURS
  def seed
    @r = RAdapter.new
    @r.cointegration_analysis(start_time_string: "'2022-06-13'",end_time_string: "'2022-07-12'")
    first_model = CointegrationModel.last&.uuid
    r_count = BacktestModel.where("version= 0 and sequence_number= 0").count
    if r_count==0
      BacktestModel.create(
        version: 0,
        model_id: first_model,
        sequence_number: 0,
        name: "seed"
      )
    end

    @RES_HOURS=1
  end
  def update_model(version:)
    last_model = BacktestModel.by_version(version).oldest_first.last&.model_id
    last_model_time = CointegrationModel.where("uuid = '#{last_model}'").last&.model_endtime
    last_candle_time = Candle.oldest_first.last&.starttime
    @r = RAdapter.new
    num_models = (last_candle_time-last_model_time)/(3600*@RES_HOURS)-1
    for i in 1..num_models
      new_end_time = last_model_time+3600*@RES_HOURS*i
      @r.cointegration_analysis(start_time_string: last_model_time, end_time_string: new_end_time)
    end
  end
end