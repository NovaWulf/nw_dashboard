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
  def test_odbc()
    @R.eval <<-EOF
      library(RODBC)
      assign("last.warning", NULL, envir = baseenv())
      dbhandle = as.vector(odbcDriverConnect('driver=./psqlodbcw.so;database=nw_server_#{Rails.env};trusted_connection=true;uid=nw_server'))
      print(warnings())
    EOF
    @R.pull "dbhandle" 
  end

  def cointegration_analysis(start_time_string:, end_time_string:)
    @R.eval <<-EOF

        source("./cointegrationAnalysis.R")

        dbhandle <- odbcDriverConnect('driver=./psqlodbcw.so;database=nw_server_#{Rails.env};trusted_connection=true;uid=nw_server')

        fitModel(dbhandle,#{start_time_string},#{end_time_string},ecdet_param = "const")

    EOF
  end
end
