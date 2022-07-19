library(data.table)
library(RODBC)
library(urca)
library(lattice)
library(latticeExtra)
library(lubridate)
library(digest)

args = commandArgs(trailingOnly=TRUE)

dbhandle <- odbcDriverConnect('driver=/usr/local/lib/psqlodbcw.so;database=nw_server_development;trusted_connection=true;uid=nw_server')
startTime = as.numeric(as.POSIXct(args[1]))
endTime = as.numeric(as.POSIXct(args[2]))
resolution = 60
ethDat = data.table(sqlQuery(dbhandle,paste0("select starttime,close from candles where pair ='eth-usd' and resolution = ", resolution)))
opDat = data.table(sqlQuery(dbhandle,paste0("select starttime,close from candles where pair = 'op-usd' and resolution= ",resolution )))


bothDat = merge(ethDat,opDat,by = "starttime")
bothDat = bothDat[starttime>startTime & starttime<endTime]
bothDat$start_datetime = as_datetime(bothDat$starttime)    

dataMat = as.matrix(bothDat[,c("close.x","close.y")])
ecdet = "const"
spec = "transitory"
type = "trace"
jo=ca.jo(dataMat,type= type,ecdet = ecdet,spec=spec)
#summary(jo)


vecs = jo@V

spread = vecs[1,1]*bothDat$close.x + vecs[2,1]*bothDat$close.y+vecs[3,1]

meanSpread= mean(spread)
sdSpread = sd(spread)

plot1 = xyplot(close.x~start_datetime,bothDat,type="l", auto.key = TRUE, main = "double axis plot of OP vs ETH futures")
plot2 = xyplot(close.y~start_datetime,bothDat,type="l",auto.key = TRUE)
doubleYScale(plot1, plot2)

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


