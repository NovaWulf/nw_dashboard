require "rinruby"

class RAdapter
    @env_name
    
    def initialize
       
        env_name = "test" 
        if Rails.env.development?
            env_name = "development"
        elsif Rails.env.production?
            env_name = "production"
        end
        @env_name = env_name
        R.eval <<-DOC
            my_packages<-c("data.table","RODBC","urca","lubridate","digest")

            install_if_missing = function(p) {
            if (p %in% rownames(installed.packages()) == FALSE) {
                install.packages(p)
            }
            }

            invisible(sapply(my_packages, install_if_missing))
            
            DOC
    end
    def run_r_script(script,returnVal)

        R.eval <<-DOC
        #{script}
        DOC
        return R.pull returnVal.to_s # Be sure to return the object assigned in R script
        
    end
    def cointegration_analysis(startTimeString: , endTimeString:)

        R.eval <<-DOC 
       
        source("./cointegrationAnalysis.R")

        dbhandle <- odbcDriverConnect('driver=./psqlodbcw.so;database=nw_server_#{@env_name};trusted_connection=true;uid=nw_server')
        
        fitModel(dbhandle,#{startTimeString},#{endTimeString},ecdet_param = "const")
        
        DOC

    end
end

