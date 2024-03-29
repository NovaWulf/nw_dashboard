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

  def cointegration_analysis(asset_names:, start_time_string:, end_time_string:, ecdet_param:)
    Rails.logger.info "creating cointegration model for pair #{asset_names} with start time #{start_time_string},
      end time #{end_time_string} ecdet_param #{ecdet_param}"
    asset_string = "c('" + asset_names.join("','") + "')"
    @R.eval <<-EOF
        print(getwd())
        source("./cointegrationAnalysis.R")
        returnVals = fitModel(#{asset_string},#{start_time_string},#{end_time_string},ecdet_param = #{ecdet_param})
    EOF
    return_vals = @R.pull 'returnVals'
    Rails.logger.info "Return Vals from R: #{return_vals}"
    write_model_to_db(return_vals: return_vals)
  end

  def write_model_to_db(return_vals:)
    cf = return_vals[0].tr('()', '').split(',')
    cv = return_vals[1].tr('()', '').split(',')
    correct_fields = %w[uuid timestamp ecdet spec cv_10_pct cv_5_pct cv_1_pct test_stat
                        top_eig resolution model_starttime model_endtime in_sample_mean in_sample_sd, log_prices]
    if cf[0] != correct_fields[0]
      Rails.logger.info 'cointegration model fields are not in the right order!'
      return
    end
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
      Rails.logger.info 'cointegration model weight fields are not in the right order!'
      return
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
    cv
  end

  def jesse_analysis
    @R.eval <<-EOF
        print(getwd())
        source("./calculateJesseModel.R")
        finalJSON = fitJesseModel()
    EOF
    final_json = @R.pull 'finalJSON'
    model_vals = write_jesse_model_to_db(final_json: final_json)
    Rails.logger.info "number of jesse models: #{JesseModel.count}"
  end

  def write_jesse_model_to_db(final_json:)
    parsed_json = JSON.parse(final_json)
    puts "parsed json: #{parsed_json.keys}"
    jesse_model = parsed_json['model']
    jesse_model_weights = parsed_json['model_weights']

    j = JesseModel.create(
      standard_error: jesse_model['standard_error'][0],
      r_squared: jesse_model['r_squared'][0],
      f_stat: jesse_model['f_stat'][0],
      adj_r_squared: jesse_model['adj_r_squared'][0],
      model_starttime: jesse_model['model_starttime'][0],
      model_endtime: jesse_model['model_endtime'][0]
    )
    names = jesse_model_weights['names']
    coefs = jesse_model_weights['coefs']

    (0..(names.length - 1)).each do |w|
      puts 'adding jesse model weight'
      puts "name: #{names[w]} coef: #{coefs[w].to_f} id: #{j&.id.to_i}"
      JesseModelWeight.create!(
        metric_name: names[w].to_s,
        weight: coefs[w].to_f,
        jesse_models_id: j&.id
      )
    end
  end
end
