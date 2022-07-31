library(data.table)
library(urca)
library(lubridate)
library(digest)
library(lattice)
library(latticeExtra)

fitModel = function(startTimeString,endTimeString,ecdet_param="const"){

startTime = startTimeString
endTime = endTimeString
if (class(startTimeString)=="character" && class(endTimeString)== "character"){
  startTime = as.numeric(strptime(startTimeString, "%Y-%m-%d"))
  endTime = as.numeric(strptime(endTimeString,"%Y-%m-%d")) 
}

resolution = 60
allDat = data.table(read.csv("./public/data.csv"))
ethDat = allDat[starttime>startTime & starttime<endTime & resolution == resolution & pair == "eth-usd"]
opDat =  allDat[starttime>startTime & starttime<endTime & resolution == resolution & pair == "op-usd"]

bothDat = merge(ethDat,opDat,by = "starttime")
bothDat = bothDat[starttime>startTime & starttime<endTime]
bothDat = bothDat[order(bothDat$starttime)]
print(dim(bothDat))
bothDat$start_datetime = as_datetime(bothDat$starttime)    

dataMat = as.matrix(bothDat[,c("close.x","close.y")])
ecdet = ecdet_param
spec = "transitory"
type = "trace"
jo=ca.jo(dataMat,type= type,ecdet = ecdet,spec=spec)
summary(jo)


vecs = jo@V

spread = NULL
if (ecdet_param == "const")
 spread = vecs[1,1]*bothDat$close.x + vecs[2,1]*bothDat$close.y+vecs[3,1]

if (ecdet_param == "none")
 spread = vecs[1,1]*bothDat$close.x + vecs[2,1]*bothDat$close.y

meanSpread= mean(spread)
sdSpread = sd(spread)
sigma = 1

plot1 = xyplot(close.x~start_datetime,bothDat,type="l", auto.key = TRUE, main = "double axis plot of OP vs ETH futures")
plot2 = xyplot(close.y~start_datetime,bothDat,type="l",auto.key = TRUE)
doubleYScale(plot1, plot2)
bothDat$upper = bothDat$meanSpread+sigma*bothDat$sdSpread
bothDat$lower = bothDat$meanSpread-sigma*bothDat$sdSpread
bothDat$spread = spread
bothDat$meanSpread = meanSpread
bothDat$sdSpread = sdSpread
xyplot(spread + meanSpread~start_datetime,bothDat,type = "l",auto.key = T,main= "mean reverting portfolio")


realStartDate = min(bothDat$start_datetime)
realEndDate = max(bothDat$start_datetime)
currentTime = round(as.numeric(as.POSIXct(Sys.time())))


forDigest = c(ecdet,
              spec,
              resolution,
              realStartDate,
              realEndDate)

uid =digest(forDigest)

valueVec = c(
        uid,
        currentTime,
        ecdet,
        spec,
        jo@cval[1,1],
        jo@cval[1,2],
        jo@cval[1,3],
        jo@teststat[1],
        jo@lambda[1],
        resolution,
        realStartDate,
        realEndDate,
        meanSpread,
        sdSpread
        )
returnVals = list()
colNameString = "(uuid, timestamp,ecdet,spec,cv_10_pct,cv_5_pct,cv_1_pct,test_stat,top_eig,resolution,model_starttime,model_endtime,in_sample_mean,in_sample_sd)"
valueString = paste0(c("(",paste0(valueVec,collapse = ","),")"),collapse = "")
queryString = paste0("insert into cointegration_models " , colNameString," values",valueString)
returnVals[[1]] = colNameString
returnVals[[2]] = valueString

print(queryString)

assetNames = c("eth-usd","op-usd","det")
assetWeights=c(vecs[1,1],vecs[2,1],vecs[3,1])

colNamesString2 = "(uuid,timestamp,asset_name,weight)"
returnVals[[3]] = colNamesString2

valStrings=rep("",3)
for (i in 1:3){
  valStrings[i]=paste0("(", paste0(c(uid,currentTime,assetNames[i],assetWeights[i]),collapse=","),")")
}
totalValString = paste0(valStrings,collapse=",")
returnVals[[4]] = totalValString
returnVals = unlist(returnVals)
print(returnVals)
return (returnVals)
}
