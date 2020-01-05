# library(data.table)
library(tidyverse)
# library(prophet)
library(quantmod)
library(rugarch)
kanzel <- data.table::fread("./kh_spots.csv")
kanzel$Ymd <- as.Date(kanzel$Ymd)
kanzel$Year <- lubridate::year(kanzel$Ymd)
kanzel$Month <- lubridate::month(kanzel$Ymd)
kanzel$Spots <- kanzel$s_n + kanzel$s_s
kanzel$Groups <- kanzel$g_n + kanzel$g_s
kanzel<-kanzel[,.(Ymd,Year,Month,g_n,s_n,g_s,s_s,R,R_n,R_s,Spots,Groups)]
df <- kanzel %>% filter(Ymd <="2019-12-31")

## Predicting Sunspot with GARCH

### IBM as Control for Predictng Time Series (GARCH)
ibm <- getSymbols("IBM",auto.assign = FALSE,src="yahoo")
ibmClose <- ibm$IBM.Close
tbl_df(ibm)
chartSeries(ibm)

### GARCH Model 1 garchOrder=c(0,1) (Akaike  4.0036)
 
ibm11 <- ugarchspec(variance.model = list(model="sGARCH",garchOrder=c(0,1)),
                   mean.model=list(armaOrder=c(1,1)),
                   distribution.model = "std")
ibmGarch1 <-ugarchfit(spec=ibm11,data=ibmClose)
ibmPredict1 <- ugarchboot(ibmGarch1,n.ahead = 30,method=c("Partial","Full")[1])
plot(ibmPredict1)

### GARCH Model 2 garchOrder=c(1,1) (Akaike 3.9422)

ibm2 <- ugarchspec(variance.model = list(model="sGARCH",garchOrder=c(1,1)),
                   mean.model=list(armaOrder=c(1,1)),
                   distribution.model = "std")
ibmGarch2 <-ugarchfit(spec=ibm2,data=ibmClose)
ibmPredict2 <- ugarchboot(ibmGarch1,n.ahead = 30,method=c("Partial","Full")[1])
plot(ibmPredict2)

### GARCH Model 3 garchOrder=c(2,2) (Akaike 3.9414)

ibm3 <- ugarchspec(variance.model = list(model="sGARCH",garchOrder=c(2,2)),
                   mean.model=list(armaOrder=c(1,1)),
                   distribution.model = "std")
ibmGarch3 <-ugarchfit(spec=ibm3,data=ibmClose)
ibmPredict3 <- ugarchboot(ibmGarch1,n.ahead = 30,method=c("Partial","Full")[1])
plot(ibmPredict3)
