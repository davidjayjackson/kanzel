library(data.table)
library(forecast)
library(ggplot2)
library(plotly)
library(xts)
library(lubridate)
library(RSQLite)
library(AutoModel)

rm(list=ls())
#
kanzel <- fread("kanzel.html")
kanzel$Ymd <- as.Date(kanzel$Ymd)
kanzel$Year <- year(kanzel$Ymd)
kanzel$Month <- month(kanzel$Ymd)
kanzel<-kanzel[,.(Ymd,g_n,s_n,g_s,s_s,R,R_n,R_s)]
# AutoModel 
run_model("R", c("g_n", "s_n","g_s", "s_s"), c("R_n", "R_s"), dataset=kanzel)
