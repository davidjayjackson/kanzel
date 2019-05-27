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
kanzel <- fread("../db/kanzel.html")
kanzel$Ymd <- as.Date(kanzel$Ymd)
kanzel$Year <- year(kanzel$Ymd)
kanzel$Month <- month(kanzel$Ymd)
kanzel<-kanzel[,.(Ymd,Year,g_n,s_n,g_s,s_s,R)]

# kanzel$Short <- ma(kanzel$R,order=27)
kanzel$Medium <- ma(kanzel$R,order=60)
# kanzel$Long <- ma(kanzel$R,order=390)
 kanzel_test <- kanzel[Year >=2014,]
kanzel_train <- kanzel[Year <2019,]
kanzel_recent <- kanzel[Year >=2019,]
# Export kanzel traing data
write.csv(kanzel,file="kanzel_recent.csv",row.names = F)
# Write Json file:
kanzel_json <- toJSON(kanzel,pretty=TRUE)
write.csv(kanzel_train,file="kanzel_train.csv",row.names = F)
write.csv(kanzel_test,file="kanzel_test.csv",row.names = F)
#
p<-ggplot(data=kanzel_test,aes(x=Ymd,y=R)) + geom_line() + geom_smooth(method="lm")
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
kanzelTemplate$Ymd <- as.Date(kanzelTemplate$Ymd)
kanzelTemplate$g_n <- as.numeric(kanzelTemplate$g_n)
kanzelTemplate$s_n <- as.numeric(kanzelTemplate$s_n)
kanzelTemplate$g_s <- as.numeric(kanzelTemplate$g_n)
kanzelTemplate$s_s <- as.numeric(kanzelTemplate$s_s)
kanzelTemplate$R <- as.numeric(kanzelTemplate$R)
kanzelTemplate$Short <- as.numeric(kanzelTemplate$Short)
kanzelTemplate$Medium <- as.numeric(kanzelTemplate$Medium)
kanzelTemplate$Long <- as.numeric(kanzelTemplate$Long)
# Write JASON template
kanzel_json <- toJSON(kanzelTemplate,pretty=TRUE)
write_json()

# AutoModel library
run_model("R", c("g_n", "s_n","g_s", "s_s"), c("R_n", "R_s"), dataset=kanzel)
formulas <- create_formula_objects("R", c("g_n","s_n","g_s","s_s"), c("R_n","R_s"))
models <- create_model_objects(formulas, dataset = kanzel)
