library(data.table)
library(forecast)
library(ggplot2)
library(plotly)
library(xts)
library(lubridate)
library(RSQLite)

rm(list=ls())
#
kanzel <- fread("../db/kanzel.html")
kanzel$Ymd <- as.Date(kanzel$Ymd)
kanzel$Year <- year(kanzel$Ymd)
kanzel$Month <- month(kanzel$Ymd)
kanzel<-kanzel[,.(Ymd,Year,Month,g_n,s_n,g_s,s_s,R_n,R_s,R)]

kanzel$Short <- ma(kanzel$R,order=27)
kanzel$Medium <- ma(kanzel$R,order=180)
kanzel$Long <- ma(kanzel$R, order=390)
kanzel_test <- kanzel[Year >=2014,]
kanzel_train <- kanzel[Year <2014,]
kanzel_recent <- kanzel[Year >=2017,]

ggplot(data=kanzel_recent,aes(x=Ymd,y=R)) + geom_line() + geom_smooth(method="loess")
ggplotly(p)
# SQLite Stuff
db <- dbConnect(SQLite(), dbname="kanzel.sqlite3")
kanzel$Ymd <- as.character(kanzel$Ymd)
dbWriteTable(db,"kanzel",kanzel, row.names=FALSE,overwrite=TRUE)
dbListTables(db)