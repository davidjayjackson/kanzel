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
kanzel<-kanzel[,.(Ymd,Year,Month,g_n,s_n,g_s,s_s,R_n,R_s,Rr,R)]

kanzel$Short <- ma(kanzel$R,order=27)
kanzel$Medium <- ma(kanzel$R,order=180)
kanzel$Long <- ma(kanzel$R, order=390)
kanzel_test <- kanzel[Ymd >=2014,]
kanzel_train <- kanzel[Ymd <2014,]

ggplot(data=kanzel,aes(x=Ymd,y=Medium)) + geom_line()
a <- ggplot(data=bremen,aes(x=Ymd,y=mgii)) + geom_line()
ggplotly(a)
#

# SQLite Stuff
db <- dbConnect(SQLite(), dbname="kanzel.sqlite3")
dbListTables(db)
kanzel$Ymd <- as.character(kanzel$Ymd)
dbWriteTable(db,"kanzel",kanzel, row.names=FALSE,overwrite=TRUE)
