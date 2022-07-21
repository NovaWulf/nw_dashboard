library(data.table)
library(RODBC)
library(urca)
library(lubridate)
library(digest)
library(lattice)
library(latticeExtra)

fitModel = function(dbhandle,startTimeString,endTimeString,ecdet_param="const"){

startTime = as.numeric(strptime(startTimeString, "%Y-%m-%d"))
endTime = as.numeric(strptime(endTimeString,"%Y-%m-%d"))

resolution = 60
ethDat = data.table(sqlQuery(dbhandle,paste0("select starttime,close from candles where pair ='eth-usd' and resolution = ", resolution)))
opDat = data.table(sqlQuery(dbhandle,paste0("select starttime,close from candles where pair = 'op-usd' and resolution= ",resolution )))


bothDat = merge(ethDat,opDat,by = "starttime")
bothDat = bothDat[starttime>startTime & starttime<endTime]
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

uid =paste0("'",digest(forDigest),"'")

valueVec = c(
        uid,
        currentTime,
        paste0("'",ecdet,"'"),
        paste0("'",spec,"'"),
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

colNameString = "(uuid, timestamp,ecdet,spec,cv_10_pct,cv_5_pct,cv_1_pct,test_stat,top_eig,resolution,model_starttime,model_endtime,in_sample_mean,in_sample_sd)"
valueString = paste0(c("(",paste0(valueVec,collapse = ","),")"),collapse = "")
queryString = paste0("insert into cointegration_models " , colNameString," values",valueString)
sqlQuery(dbhandle,queryString)

assetNames = c("'eth-usd'","'op-usd'","'det'")
assetWeights=c(vecs[1,1],vecs[2,1],vecs[3,1])

colNamesString2 = "(uuid,timestamp,asset_name,weight)"

valStrings=rep("",3)
for (i in 1:3){
  valStrings[i]=paste0("(", paste0(c(uid,currentTime,assetNames[i],assetWeights[i]),collapse=","),")")
}
totalValString = paste0(valStrings,collapse=",")

sqlQuery(dbhandle,paste0("insert into cointegration_model_weights ",colNamesString2," values ",totalValString))

return (summary(jo))
}
