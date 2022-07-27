class RAdapter
  require 'rinruby'
  def initialize
    @R = RinRuby.new
    @R.eval <<-EOF
            my_packages<-c("data.table","RODBC","urca","lubridate","digest","lattice","latticeExtra")

            install_if_missing = function(p) {
              if (p %in% rownames(installed.packages()) == FALSE) {
                  install.packages(p, repos='http://cran.us.r-project.org')
              }
            }

            invisible(sapply(my_packages, install_if_missing))

    EOF
  end

  def run_r_script(script, return_val)
    @R.eval <<-EOF
        #{script}
    EOF
    @R.pull return_val.to_s # Be sure to return the object assigned in R script
  end

  def cointegration_analysis(start_time_string:, end_time_string:)
    @R.eval <<-EOF

        source("./cointegrationAnalysis.R")

        dbhandle <- odbcDriverConnect('driver=./psqlodbcw.so;database=nw_server_#{Rails.env};trusted_connection=true;uid=nw_server')

        fitModel(dbhandle,#{start_time_string},#{end_time_string},ecdet_param = "const")

    EOF
  end
end
