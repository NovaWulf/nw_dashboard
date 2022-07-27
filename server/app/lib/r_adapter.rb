class RAdapter
  require 'rinruby'
  def initialize
    @R = RinRuby.new
    @R.eval <<-DOC
            my_packages<-c("data.table","urca","lubridate","digest","lattice","latticeExtra")

            install_if_missing = function(p) {
              if (p %in% rownames(installed.packages()) == FALSE) {
                  install.packages(p, repos='http://cran.us.r-project.org')
              }
            }

            invisible(sapply(my_packages, install_if_missing))

    DOC
  end

  def run_r_script(script, return_val)
    @R.eval <<-DOC
        #{script}
    DOC
    @R.pull return_val.to_s # Be sure to return the object assigned in R script
  end

  def cointegration_analysis(start_time_string:, end_time_string:)
    @R.eval <<-DOC

        source("./cointegrationAnalysis.R")

        dbhandle <- odbcDriverConnect('driver=./psqlodbcw.so;database=nw_server_#{Rails.env};trusted_connection=true;uid=nw_server')

        fitModel(dbhandle,#{start_time_string},#{end_time_string},ecdet_param = "const")

    DOC
  end
end
