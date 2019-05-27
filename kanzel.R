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
kanzel<-kanzel[,.(Ymd,g_n,s_n,g_s,s_s,R)]

kanzel$Short <- ma(kanzel$R,order=27)
kanzel$Medium <- ma(kanzel$R,order=60)
kanzel$Long <- ma(kanzel$R,order=390)
# kanzel_test <- kanzel[Year >=2014,]
# kanzel_train <- kanzel[Year <2014,]
kanzel_recent <- kanzel[Year >=2019,]
# Export kanzel traing data
write.csv(kanzel,file="kanzel_auto.csv",row.names = F)
# Write Json file:
kanzel_json <- toJSON(kanzel,pretty=TRUE)
# write.csv(kanzel_train,file="kanzel_train.csv",row.names = F)
# write.csv(kanzel_test,file="kanzel_test.csv",row.names = F)
ggplot(data=kanzel_test,aes(x=Ymd,y=Medium)) + geom_line() + geom_smooth(method="lm")
ggplotly(p)
# SQLite Stuff
db <- dbConnect(SQLite(), dbname="kanzel.sqlite3")
kanzel$Ymd <- as.character(kanzel$Ymd)
dbWriteTable(db,"kanzel",kanzel, row.names=FALSE,overwrite=TRUE)
dbListTables(db)
#
# Create prediction JSON file:
library(jsonlite)
kanzelTemplate <- fread("../db/predict_kanzel.csv")
sidcTemplate$Ymd <- as.Date(kanzelTemplate$Ymd)
kanzelTemplate$g_n <- as.numeric(kanzelTemplate$g_n)
kanzelTemplate$s_n <- as.numeric(kanzelTemplate$s_n)
kanzelTemplate$g_s <- as.numeric(kanzelTemplate$g_n)
kanzelTemplate$s_s <- as.numeric(kanzelTemplate$s_s)
kanzelTemplate$Short <- as.numeric(kanzelTemplate$g_Short)
kanzelTemplate$Medium <- as.numeric(kanzelTemplate$Medium)
kanzelTemplate$Long <- as.numeric(kanzelTemplate$Long)

