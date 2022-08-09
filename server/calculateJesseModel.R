
fitJesseModel = function(startTimeString,endTimeString){
  print("does file ./public/metrics.csv exist in r?")
  print(file.exists("./public/metrics.csv"))
  
  startTime = startTimeString
  endTime = endTimeString
  if (class(startTimeString)=="character" && class(endTimeString)== "character"){
    startTime = as.numeric(strptime(startTimeString, "%Y-%m-%d",tz="EST"))
    endTime = as.numeric(strptime(endTimeString,"%Y-%m-%d",tz="EST")) 
  }
  allDat = read.csv("./public/metrics.csv")
  print(names(allDat))
  print(dim(allDat))
  
  #dcast(allDat, family_id + age_mother ~ child, value.var = "dob")
  
} 

fitJesseModel("2022-01-01","2022-08-01")
