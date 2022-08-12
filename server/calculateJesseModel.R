library(jsonlite)
library(data.table)
fitJesseModel = function(){
  print("does file ./public/metrics.csv exist in r?")
  print(file.exists("./public/metrics.csv"))
  

  allDat = data.table(read.csv("./public/metrics.csv"))
  print(names(allDat))
  print(dim(allDat))
  castDat = dcast(allDat, timestamp~metric, value.var = "value",fun = max)
  
  castDat = castDat[!is.na(castDat$active_addresses) 
                    &!is.na(castDat$google_trends)
                    &!is.na(castDat$hash_rate) 
                    &!is.na(castDat$s2f_ratio) ]
  castDat[,metric:=NULL]
  castDat=castDat[1:nrow(castDat)-1]
  
  castDat$timestamp = as.Date(castDat$timestamp)
  castDat$active_addresses=as.numeric(castDat$active_addresses)
  castDat$active_addresses_sq=castDat$active_addresses*castDat$active_addresses
  castDat$google_trends=as.numeric(castDat$google_trends)
  castDat$hash_rate=as.numeric(castDat$hash_rate)
  castDat$s2f_ratio=as.numeric(castDat$s2f_ratio)
  castDat$price = as.numeric(castDat$price)
  modelStartDate = min(as.numeric(strptime(as.character(castDat$timestamp), "%Y-%m-%d",tz="EST")))
  modelEndDate = max(as.numeric(strptime(as.character(castDat$timestamp), "%Y-%m-%d",tz="EST")))
  model = lm(price~active_addresses_sq + google_trends+hash_rate+s2f_ratio,castDat)
  model_summary = summary(model)
  rSquared = model_summary$r.squared
  standardError = model_summary$sigma
  adjRSquared = model_summary$adj.r.squared
  fStat = model_summary$fstatistic
  coefs = model$coefficients
  modelReturnVals = list()
  modelReturnVals[["standard_error"]] = standardError
  modelReturnVals[["r_squared"]] = rSquared
  modelReturnVals[["f_stat"]] = fStat
  modelReturnVals[["adj_r_squared"]] = adjRSquared
  modelReturnVals[["model_starttime"]] = modelStartDate
  modelReturnVals[["model_endtime"]] = modelEndDate
  modelWeightReturnVals = list()
  modelWeightReturnVals[["coefs"]] = coefs
  modelWeightReturnVals[["names"]] = names(coefs)
  returnVals = list()
  returnVals[["model"]]=modelReturnVals
  returnVals[["model_weights"]] = modelWeightReturnVals
  finalJSON = as.character(toJSON(returnVals))
  print("finalJSON")
  print(finalJSON)
  return(finalJSON)
} 