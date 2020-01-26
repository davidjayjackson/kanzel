library(tidyverse)
library(prophet)
library(lubridate)
library(xts)
df <- data.table::fread("../db/kh_spots.csv")
df$Ymd <- as.Date(df$Ymd)
df$Cts <- ifelse(df$R >0,1,0)
df <- df %>% select(Ymd,R)
colnames(df) <- c("ds","y")
summary(df)
# Begin Prediction
m <- prophet(seasonality.mode="multiplicative")
m <- add_seasonality(m, name="cycle_11year", period=365.25 * 11,fourier.order=5)
m <- fit.prophet(m, df)
future <- make_future_dataframe(m,periods=4000,freq="day")
forecast <- predict(m, future)
plot(m,forecast) + ggtitle("Kanzel Observatory ISN: 1944 - 2022") + 
  xlab("Year of Prediction") + ylab("Mean ISN")
## Sub plot for 2019 - 2-22
forecast1 <- forecast %>% filter(ds >="2020-01-01" & ds <="2022-12-31") %>% select(ds,yhat)
ggplot(data=forecast1,aes(x=ds,y=yhat)) +geom_line() + 
  geom_smooth() +labs(title="Kanzel Observatory ISN Prediction: 2020 - 2023",
                            subtitle="Cycle 25 and Beyond") + 
                    xlab("Date") + ylab("Mean ISN")



df1 <- df %>% filter(Ymd >="2009-01-01")
df$Cts <- ifelse(df$s_n>=1,"North","South")
ggplot(df1,aes(x=R_s,y=R_n)) + geom_point() +geom_smooth(method=glm) +
    ggtitle("ISN/Rn: Ratio of North to South: 2009-2019") +xlab("South ISN/Rn") + ylab("North ISN/Rn")

barplot(table(df$Cts))
ggplot(table(df),aes(x=Cts)) +geom_bar() 
##
## Decade of the 60's
df2 <- df %>% filter(Ymd >="1960-01-01" & Ymd <="1970-12-31")
ggplot(df2,aes(x=R_s,y=R_n)) + geom_point() +geom_smooth(method=glm) +
    ggtitle("ISN/Rn: Ratio of North to South: 1960-1970") +xlab("South ISN/Rn") + ylab("North ISN/Rn")

barplot(table(df2$Cts),main="Decade of the 60's")
ggplot(table(df2),aes(x=Cts)) +geom_col() 
## Decade of 50's
df3 <- df %>% filter(Ymd >="1949-01-01" & Ymd <="1959-12-31")
ggplot(df3,aes(x=R_s,y=R_n)) + geom_point() +geom_smooth(method=glm) +
    ggtitle("ISN/Rn: Ratio of North to South: 1949-1959") +xlab("South ISN/Rn") + ylab("North ISN/Rn")

df2$Cts <- ifelse(df2$s_n>=1,"North","South")
barplot(table(df2$Cts),main="Decade of the 50's")
## 
## Use XTS to calc days with sunspots by year and month
df.cts <- df %>% filter(df$Cts ==1) 
isn.xts <- xts(x = df.cts$Cts, order.by = df.cts$Ymd)
str(isn.xts)
isn.monthly <- apply.monthly(isn.xts, sum)
DT <- data.table::as.data.table(isn.monthly)
colnames(DT) <- c("Ymd","Counts")
DT1 <- DT %>% filter(Counts >=10 & Ymd >="2018-01-01") 
  ggplot(DT1,aes(x=Ymd,y=Counts)) + geom_col()
## Janurary Numbers
DT$Year <- year(DT$Ymd)
DT$Month <- month(DT$Ymd)
DT %>% filter(Year >=2014 & Month ==1) %>% 
  ggplot() + geom_col(aes(x=Ymd,y=Counts))

df %>% filter(Ymd >="2018-01-01") %>%
  ggplot() +geom_line(aes(x=Ymd,y=s_n,col="s_n")) +
  geom_line(aes(x=Ymd,y=s_s,col="s_s")) +
  ggtitle("Kanzel North/South: 2018 - 2019") +
  ylab("Number of Spots")