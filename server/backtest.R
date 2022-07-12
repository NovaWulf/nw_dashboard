library(data.table)
library(RODBC)
library(aTSA)
library(urca)
library(lattice)
library(latticeExtra)
library(lubridate)

dbhandle <- odbcDriverConnect('driver=/usr/local/lib/psqlodbcw.so;database=nw_server_development;trusted_connection=true')
startTime = as.numeric(as.POSIXct("2022-06-13 "))
ethDat = data.table(sqlQuery(dbhandle,paste0("select starttime,close from candles where pair ='eth-usd' and resolution = 60 and starttime > ",startTime)))
opDat = data.table(sqlQuery(dbhandle,paste0("select starttime,close from candles where pair = 'op-usd' and resolution= 60 and starttime > ",startTime)))



bothDat = merge(ethDat,opDat,by = "starttime")

bothDat$start_datetime = as_datetime(bothDat$starttime)    

head(bothDat)
ct = coint.test(bothDat$close.x,bothDat$close.y,d=0)
summary(ct)
dataMat = as.matrix(bothDat[,c("close.x","close.y")])
jo=ca.jo(dataMat,type= "trace",ecdet = "const",spec="transitory")
summary(jo)
plot1 = xyplot(close.x~start_datetime,bothDat,type="l", auto.key = TRUE, main = "double axis plot of OP vs ETH futures")
plot2 = xyplot(close.y~start_datetime,bothDat,type="l",auto.key = TRUE)
doubleYScale(plot1, plot2)


vecs = jo@V
spread = vecs[1,1]*bothDat$close.x + vecs[2,1]*bothDat$close.y+vecs[3,1]
bothDat$spread = spread

meanSpread= mean(spread)
sdSpread = sd(spread)

bothDat$meanSpread = meanSpread
bothDat$sdSpread = sdSpread
xyplot(spread + meanSpread~start_datetime,bothDat,type = "l",auto.key = T,main= "mean reverting portfolio")

sigma = 1
position = 0
balances = rep(0,length(spread))
positions = rep(0,length(spread))
profits = rep(0,length(spread))
tradeSize = 1000

lastSpread = spread[1]
lastPosition = 0
lastBalance = 0
for (i in 1:length(spread)){
  thisVal = spread[i]
  profits[i] = lastBalance*(thisVal-lastSpread)
  
  if (lastPosition !=-1 && thisVal>meanSpread+sigma*sdSpread){
    positions[i]=-1
    balances[i] = -tradeSize
  } else {
    if (lastPosition != 1 && thisVal<meanSpread-sigma*sdSpread){
      positions[i] = 1
      balances[i] = tradeSize
    } else {
      positions[i]=positions[i-1]
      balances[i] = balances[i-1]
    }
  }
  lastPosition = positions[i]
  lastSpread = spread[i]
  lastBalance = balances[i]
  #print(position)
}
PnL = cumsum(profits)
plot(PnL)

bothDat$upper = bothDat$meanSpread+sigma*bothDat$sdSpread
bothDat$lower = bothDat$meanSpread-sigma*bothDat$sdSpread
bothDat$PnL = PnL
plot3 = xyplot(spread + meanSpread + upper+lower~start_datetime,bothDat,type = "l",auto.key = T,main= "mean reverting portfolio")
plot4 = xyplot(PnL~start_datetime,bothDat,type = "l",main= "PnL of arb strategy with 1000 ETH")
plot3
plot4
doubleYScale(plot4, plot3)
