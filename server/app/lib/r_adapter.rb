class RAdapter
  require 'rinruby'
  def initialize
    @R = RinRuby.new
  end

  def run_r_script(script, return_val)
    @R.eval <<-EOF
        #{script}
    EOF
    @R.pull return_val.to_s
  end

  def cointegration_analysis(start_time_string:, end_time_string:, ecdet_param:)
    @R.eval <<-EOF
        print(getwd())
        source("./cointegrationAnalysis.R")
        returnVals = fitModel(#{start_time_string},#{end_time_string},ecdet_param = #{ecdet_param})
    EOF
    return_vals = @R.pull 'returnVals'
    model_vals = write_model_to_db(return_vals: return_vals)
    Rails.logger.info "number of cointegration models: #{CointegrationModel.count}"
    puts "returning model vals: #{model_vals}"
    model_vals
  end

  def write_model_to_db(return_vals:)
    cf = return_vals[0].tr('()', '').split(',')
    cv = return_vals[1].tr('()', '').split(',')
    correct_fields = %w[uuid timestamp ecdet spec cv_10_pct cv_5_pct cv_1_pct test_stat
                        top_eig resolution model_starttime model_endtime in_sample_mean in_sample_sd, log_prices]
    abort('cointegration model fields are not in the right order!') if cf[0] != correct_fields[0]
    puts "correct fields: #{correct_fields[0]}"
    model_count = CointegrationModel.where("uuid='#{cv[0]}'").count
    if model_count == 0
      CointegrationModel.create(
        uuid: cv[0],
        timestamp: cv[1],
        ecdet: cv[2],
        spec: cv[3],
        cv_10_pct: cv[4],
        cv_5_pct: cv[5],
        cv_1_pct: cv[6],
        test_stat: cv[7],
        top_eig: cv[8],
        resolution: cv[9],
        model_starttime: cv[10],
        model_endtime: cv[11],
        in_sample_mean: cv[12],
        in_sample_sd: cv[13],
        log_prices: cv[14]
      )
    end
    cwf = return_vals[2].tr('()', '').split(',')

    if cwf != %w[uuid timestamp asset_name weight]
      abort('cointegration model weight fields are not in the right order!')
    end

    cwv = return_vals[3].split('),(')
    for i in 0..(cwv.length - 1)
      this_cwv = cwv[i].tr('()', '').split(',')
      model_weight_count = CointegrationModelWeight.where("uuid = '#{this_cwv[0]}' and asset_name = '#{this_cwv[2]}'").count
      next unless model_weight_count == 0

      CointegrationModelWeight.create(
        uuid: this_cwv[0],
        timestamp: this_cwv[1],
        asset_name: this_cwv[2],
        weight: this_cwv[3]
      )
    end
    puts "returning model values: #{cv}"
    puts "cv[9]: #{cv[9]} cv10: #{cv[10]}"
    cv
  end
end
