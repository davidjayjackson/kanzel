library(prophet)
library(readr)
write.csv(df,file="data.csv",row.names = F)
df <- read_csv("data.csv")
# cols(ds = col_date(format = ""),y = col_double())
#
# Quick plot
# The challenge of predicting Sonspot activity is that
# every (depending on your point of view) 11 years there is a
# Solar maxium or Solar miniumim.
#
plot(df$ds,df$y,'l')
#
m <- prophet(df,yearly.seasonality = "auto",fit=TRUE)
future <- make_future_dataframe(m,periods=180,freq="day")
head(future)
tail(future)
#
forecast <- predict(m,future)
head(forecast)
tail(forecast)
#
plot(m,forecast)
#
prophet_plot_components(m, forecast)
#
