library(ggplot2)
library(tidyverse)  
library(zoo)   
library(dplyr)
library(qcc)
library(lubridate)
library(stats)
library(forecast)

#For the first-order exponential smoothing, measures of accuracy such as
#MAPE, MAD, and MSD can be obtained from the following function:
measacc.fs <- function(y,lambda){
  out <- firstsmooth(y,lambda)
  T <- length(y)
  #Smoothed version of the original is the one step ahead prediction
  #Hence the predictions (forecasts) are given as
  pred <- c(y[1],out[1:(T-1)])
  prederr <- y-pred
  SSE <- sum(prederr^2)
  MAPE <- 100*sum(abs(prederr/y))/T
  MAD <- sum(abs(prederr))/T
  MSD <- sum(prederr^2)/T
  ret1 <- c(SSE,MAPE,MAD,MSD)
  names(ret1) <- c("SSE","MAPE","MAD","MSD")
  return(ret1)
  return(prederr)
}

# Dr Jha's first-order exponential smoothing function
firstsmooth <- function(y, lambda, start=y[1]){
  ytilde <- y
  ytilde[1] <- lambda*y[1] + (1-lambda)*start
  for (i in 2:length(y)){
    ytilde[i] <- lambda*y[i] + (1-lambda)*ytilde[i-1]
  }
  ytilde
}

# Dr Jha's AIC function
aic_J <- function(model, series){
  return(-2 * model$loglik + (log(length(series)) + 1) * length(model$coef))
}

# Modified version of Dr Jha's function to find the best SARIMA orders
get.best.sarima <- function(x.ts, maxord = c(1,1,1,1,1,1), freq = frequency(x.ts)){
  best.aic <- 1e8
  n <- length(x.ts)
  print(paste0("frequency: ", freq))
        for (p in 0:maxord[1]) for(d in 0:maxord[2]) for(q in 0:maxord[3])
          for (P in 0:maxord[4]) for(D in 0:maxord[5]) for(Q in 0:maxord[6]){
            fit <- arima(x.ts
                         , order = c(p,d,q)
                         , seas = list(order = c(P,D,Q), freq)
                         , method = "CSS")
            
            fit.aic <- -2 * fit$loglik + (log(n) + 1) * length(fit$coef)
            
            if (fit.aic < best.aic){
              best.aic <- fit.aic
              best.fit <- fit
              best.model <- c(p,d,q,P,D,Q)
            }
          }
        list(best.aic, best.fit, best.model)
}

#' Residual Analysis function
#' Creates 2x2 plots to analyze residuals
analyze_residuals <- function(res, fit){
  par(mfrow=c(2,2), oma=c(0,0,0,0))  #2x2 Plotting area for residual analysis
  
  qqnorm(res, datax=TRUE, pch=16, xlab='Residual', main='')
  qqline(res, datax=TRUE)
  plot(fit, res, pch=16, 
       xlab='Fitted Value', ylab='Residual')
  abline(h=0)
  hist(res, col="gray", xlab='Residual', main='')
  plot(res, type="l", xlab='Observation Order', ylab='Residual')
  points(res, pch=16, cex=0.5)
  abline(h=0)
  
  par(mfrow=c(1,1))  #Reset plotting area
}

# ACF/PACF Plot function
# Creates 2x1 plots to view ACF and PACF
acf_plot <- function(series, title = "series", max_lag = 25){
  par(mfrow=c(2,1), oma=c(0,0,0,0))
  acf(series, lag.max=max_lag, type="correlation", main=paste("ACF for", title))
  acf(series, lag.max=max_lag, type="partial",     main=paste("PACF for", title))
  par(mfrow=c(1,1))
}

# Question 1 ----
data.MA.a <- 40 + arima.sim(list(order=c(0,0,1), ma=-.8), n=100)
acf_plot(data.MA.a, "MA(1) Series A")

data.MA.b <- 40 + arima.sim(list(order=c(0,0,1), ma=.8), n=100)
acf_plot(data.MA.b, "MA(1) Series B")

data.AR.a <- 8 + arima.sim(list(order=c(1,0,0), ar=-.8), n=100)
acf_plot(data.AR.a, "AR(1) Series A")

data.AR.b <- 8 + arima.sim(list(order=c(1,0,0), ar=.8), n=100)
acf_plot(data.AR.b, "AR(1) Series B")

data.ARMA.a <- 16 + arima.sim(list(order=c(1,0,1), ar=.6, ma=.8), n=100)
acf_plot(data.ARMA.a, "ARMA(1) Series A")

data.ARMA.b <- 16 + arima.sim(list(order=c(1,0,1), ar=.7, ma=.6), n=100)
acf_plot(data.ARMA.b, "ARMA(1) Series B")

# Question 2 (5.5)----

df_5_5 <- 150 - arima.sim(list(order=c(1,0,0), ar=-.5), n=100)
plot(df_5_5, type = 'l')
abline(h = 150)
acf_plot(df_5_5, "yt = 150 - 0.5(yt-1) + et")

# Question 3 (5.7)----

df_5_7 <- 20 + arima.sim(list(order=c(0,0,1), ma=.2), n=100)
plot(df_5_7, type = 'l')
abline(h = 20)
acf_plot(df_5_7, "yt = 20 + et + 0.2(et-1)")

# Question 4 (5.20) ----
df_5_20 <- read.csv("set_4_data/b.8.csv")$Unemployment[1:504]
df_5_20.ts <- ts(df_5_20, start = 1963, frequency = 12)

plot(df_5_20.ts, type = "l")
acf_plot(df_5_20.ts, max_lag = 250, "monthly unemployment rate")

# First difference
df_5_20.diff1 <- diff(df_5_20.ts, lag = 1)
acf_plot(df_5_20.diff1, max_lag = 250, "monthly unemployment rate first difference")

# Seasonal difference
df_5_20.diff2 <-  diff(df_5_20.diff1, lag = 12)
acf_plot(df_5_20.diff2, max_lag = 250, "monthly unemployment rate seasonal difference (+ first difference)")

# SARIMA(0,1,1)(0,1,1)[12]
df_5_20.model1 <- arima(df_5_20.ts, order=c(0,1,1), seasonal = list(order=c(0,1,1), period=12))
df_5_20.model1.res <- as.vector(residuals(df_5_20.model1))
df_5_20.model1.fit <- as.vector(fitted(df_5_20.model1))
df_5_20.model1.aic <- aic_J(df_5_20.model1, df_5_20.ts)
analyze_residuals(df_5_20.model1.res, df_5_20.model1.fit)

# SARIMA(0,1,0)(1,0,1)[12]
df_5_20.model2 <- arima(df_5_20.ts, order=c(0,1,0), seasonal = list(order=c(1,0,1), period=12))
df_5_20.model2.res <- as.vector(residuals(df_5_20.model2))
df_5_20.model2.fit <- as.vector(fitted(df_5_20.model2))
df_5_20.model1.aic <- aic_J(df_5_20.model2, df_5_20.ts)
analyze_residuals(df_5_20.model2.bres, df_5_20.model2.fit)

plot(df_5_20, type = "l", ylim = c(0,15))
lines(df_5_20.model1.fit, col = "red")
lines(df_5_20.model2.fit, col = "blue")

get.best.sarima(df_5_20.ts) # (0,1,0) (1,0,1)

# Question 5 (5.21) -----
df_5_21.ts <- df_5_20.ts

# Values of lambda to test
lambdas <- seq(0.01, 0.99, 0.01)
df_5_21.SSE <- lambdas

# Measure model accuracy at each value of lambda
df_5_21.SSE_fxn <- function(sc){measacc.fs(df_5_21.ts, sc)[1]}
df_5_21.SSE_vec <- sapply(lambdas, df_5_21.SSE_fxn) #SAPPLY instead of "for" loops for computational purpose
df_5_21.opt_lambda <- lambdas[df_5_21.SSE_vec == min(df_5_21.SSE_vec)] #Optimal lambda that minimizes SSE
plot(y = df_5_21.SSE_vec, x = lambdas)

# SES with optimal value of lambda that minimizes SSE
df_5_21.ses <- firstsmooth(y = df_5_21.ts, lambda = df_5_21.opt_lambda)
plot(df_5_20.ts, type = "l")
lines(df_5_21.ses, col = "blue")

# Question 6 (5.42) ----
df_5_42 <- read.csv("set_4_data/b.23.csv")
df_5_42$i <- 1:nrow(df_5_42)

# Split where forecasts will be made
df_5_42.train <- df_5_42[1:692,]
df_5_42.test <- df_5_42[693:nrow(df_5_42),]

# Time series object to train model
df_5_42.ts <- ts(df_5_42.train$positive_percent, freq=(365.25/7), start=decimal_date(ymd("1997-9-29")))


# View data
plot(df_5_42.train$positive_percent, type = "l")
acf_plot(df_5_42.train$positive_percent, max_lag = 150, "positive flu rate")

# First difference
df_5_42.diff1 <- diff(df_5_42.train$positive_percent, 1)
acf_plot(df_5_42.diff1, "differenced positive flu rate")

# ARIMA(0,0,1)
df_5_42.model1 <- arima(df_5_42.train$positive_percent, order=c(0,0,1))
df_5_42.model1.res <- as.vector(residuals(df_5_42.model1))
df_5_42.model1.fit <- as.vector(fitted(df_5_42.model1))
df_5_42.model1.aic <- aic_J(df_5_42.model1, df_5_42.train$positive_percent) #4240
analyze_residuals(df_5_42.model1.res, df_5_42.model1.fit)

# SARIMA(0,0,1)(1,0,1)[52]
df_5_42.model2 <- arima(df_5_42.train$positive_percent, order=c(0,0,1), seasonal = list(order = c(1,0,1), period = (365.25/7)))
df_5_42.model2.res <- as.vector(residuals(df_5_42.model2))
df_5_42.model2.fit <- as.vector(fitted(df_5_42.model2))
df_5_42.model2.aic <- aic_J(df_5_42.model2, df_5_42.train$positive_percent) # 4136
analyze_residuals(df_5_42.model2.res, df_5_42.model2.fit)

# SARIMA(0,0,1)(0,1,1)[52]
df_5_42.model3 <- arima(df_5_42.ts, order=c(0,0,1), seasonal = list(order = c(0,1,1), period = (365.25/7)))
df_5_42.model3.res <- as.vector(residuals(df_5_42.model3))
df_5_42.model3.fit <- as.vector(fitted(df_5_42.model3))
df_5_42.model3.aic <- aic_J(df_5_42.model3, df_5_42.train$positive_percent) # 3866
analyze_residuals(df_5_42.model3.res, df_5_42.model3.fit)

# get.best.sarima(df_5_42.ts) -> 1 1 1 0 1 1
#  SARIMA(1,1,1)(0,1,1)[52]
df_5_42.model4 <- arima(df_5_42.ts, order=c(1,1,1), seasonal = list(order = c(0,1,1), period = (365.25/7)))
df_5_42.model4.res <- as.vector(residuals(df_5_42.model4))
df_5_42.model4.fit <- as.vector(fitted(df_5_42.model4))
df_5_42.model4.aic <- aic_J(df_5_42.model4, df_5_42.train$positive_percent) # 2523
analyze_residuals(df_5_42.model4.res, df_5_42.model4.fit)

# View models
plot(df_5_42.train$positive_percent[100:300], type = "l")
lines(df_5_42.model1.fit[100:300], col = "red") 
lines(df_5_42.model2.fit[100:300], col = "green")
lines(df_5_42.model3.fit[100:300], col = "orange")
lines(df_5_42.model4.fit[100:300], col = "blue") # Best

get.best.sarima(df_5_42.train$positive_percent) # 1 0 0 1 0 1


# One-week ahead forecasts
# df_5_42.forecast_model <- df_5_42.model4
# df_5_42.fc.mean <- NULL
# df_5_42.fc.lower <- NULL
# df_5_42.fc.upper <- NULL
# 
# for (i in 1:nrow(df_5_42.test)){
#   new_forecasts <- forecast(df_5_42.forecast_model, h = 1)
#   # Get forecasts for 1 week ahead
#   df_5_42.fc.mean <-  c(as.numeric(df_5_42.fc.mean) , new_forecasts$mean[1])
#   df_5_42.fc.lower <- c(as.numeric(df_5_42.fc.lower), new_forecasts[['lower']][1,2])
#   df_5_42.fc.upper <- c(as.numeric(df_5_42.fc.upper), new_forecasts[['upper']][1,2])
#   
#   df_5_42.forecast_model <- df_5_42[1:(692+i),]$positive_percent %>% #Append next observation to current model
#     ts(start = 1995, frequency = 12) %>% #Convert to timeseries
#     arima(order=c(1,0,0), seasonal = list(order = c(0,1,1), period = (365.25/7))) # Fit model to current data
#   
#   print(i)
# }
# saveRDS(c(df_5_42.fc.mean, df_5_42.fc.lower, df_5_42.fc.upper), "5_42_111011.rds")
data <- readRDS("5_42.rds") # Load data from RDS so I don't have to wait each time
df_5_42.fc.mean  <- data[1:nrow(df_5_42.test)]
df_5_42.fc.lower <- data[(nrow(df_5_42.test)+1):(2*nrow(df_5_42.test))]
df_5_42.fc.upper <- data[(2*nrow(df_5_42.test)+1):(3*nrow(df_5_42.test))]

plot(df_5_42[693:nrow(df_5_42),]$positive_percent, type = "l", ylim = c(0,60))
lines(df_5_42.fc.mean, col = "red")
lines(df_5_42.fc.lower, col = "blue")
lines(df_5_42.fc.upper, col = "blue")


df_5_42.fc.res <- (df_5_42.fc.mean - c(df_5_42[693:nrow(df_5_42),]$positive_percent))
analyze_residuals(df_5_42.fc.res, c(df_5_42.fc.mean))

# Question 7 (5.48) ----
df_5_48 <- read.csv("set_4_data/b.27.csv")[1:218,] %>%
  mutate(date = mdy(date)
         , yt = as.numeric(on_time_arrival_perc)) %>%
  select(date, yt)

# Split where forecasts will be made
df_5_48.train <- df_5_48[1:168,]
df_5_48.test <- df_5_48[169:nrow(df_5_48),]

# Time series object to train model
df_5_48.ts <- ts(df_5_48.train$yt, start = 1995, frequency = 12)

# View data
plot(df_5_48$yt, type = "l")
acf_plot(df_5_48$yt, max_lag = 150, "airline on time arrival percentage")

# First difference
df_5_48.diff1 <- diff(df_5_48$yt, 1)

# Seasonal difference
df_5_48.diff2 <- diff(df_5_48.diff1, 12)

acf_plot(df_5_48.diff1, max_lag = 150, "airline on time arrival percentage first difference")

#ARIMA(1,0,0)(0,1,1)[12]
df_5_48.model1 <- arima(df_5_48.ts, order=c(1,0,0), seasonal = list(order = c(0,1,1), period = 12))
df_5_48.model1.res <- as.vector(residuals(df_5_48.model1))
df_5_48.model1.fit <- as.vector(fitted(df_5_48.model1))
df_5_48.model1.aic <- aic_J(df_5_48.model1, df_5_48.ts) #866
analyze_residuals(df_5_48.model1.res, df_5_48.model1.fit)

# View model
plot(df_5_48$yt, type = "l")
lines(df_5_48.model1.fit, col = "blue")

# One-year ahead forecasts
df_5_48.forecast_model <- df_5_48.model1
df_5_48.fc.mean <- NULL
df_5_48.fc.lower <- NULL
df_5_48.fc.upper <- NULL

for (i in 1:nrow(df_5_48.test)){
  new_forecasts <- forecast(df_5_48.forecast_model, h = 12)
  # Get forecasts for 12 months ahead
  df_5_48.fc.mean <- c(as.numeric(df_5_48.fc.mean), new_forecasts$mean[12])
  df_5_48.fc.lower <-c(as.numeric(df_5_48.fc.lower), new_forecasts[['lower']][12,2])
  df_5_48.fc.upper <- c(as.numeric(df_5_48.fc.upper), new_forecasts[['upper']][12,2])
  
  df_5_48.forecast_model <- df_5_48.train$yt %>%
    c(df_5_48.test$yt[i]) %>% #Append next observation to current model
    ts(start = 1995, frequency = 12) %>% #Convert to timeseries
    arima(order=c(0,1,1), seasonal = list(order = c(0,1,1), period = 12)) # Fit model to current data
}

plot(df_5_48[169:nrow(df_5_48),]$yt, type = "l", ylim = c(0, 100))
lines(df_5_48.fc.mean, col = "red")
lines(df_5_48.fc.lower, col = "blue")
lines(df_5_48.fc.upper, col = "blue")

df_5_48.fc.res <- (df_5_48.fc.mean - c(df_5_48[169:nrow(df_5_48),]$yt))
analyze_residuals(df_5_48.fc.res, c(df_5_48.fc.mean))

get.best.sarima(df_5_48.ts) # 1 0 0 0 1 1

# Question 8 (5.49) -----
df_5_49 <- read.csv("set_4_data/b.28.csv")[1:288,] %>%
  select(month = Month, yt = auto_ship_mil_dollars)

# Time series object to train model
df_5_49.ts <- ts(df_5_49$yt, start = 1992, frequency = 12)

# View data
plot(df_5_49.ts, type = "l")
acf_plot(df_5_49.ts, max_lag = 150, "domestic autombile shipments (mil dollars)")

# First difference
df_5_49.diff1 <- diff(df_5_49$yt, 1)
acf_plot(df_5_49.diff1, max_lag = 150, "domestic autombile shipments (mil dollars) first differnce")

# Seasonal difference
df_5_49.diff2 <- diff(df_5_49$yt, 12)
acf_plot(df_5_49.diff2, max_lag = 150,"domestic autombile shipments (mil dollars) seasonal difference (+first difference)")

# ARIMA(2,0,0)
df_5_49.model1 <- arima(df_5_49.ts, order=c(2,0,0))
df_5_49.model1.res <- as.vector(residuals(df_5_49.model1))
df_5_49.model1.fit <- as.vector(fitted(df_5_49.model1))
df_5_49.model1.aic <- aic_J(df_5_49.model1, df_5_49.ts) # 4981
analyze_residuals(df_5_49.model1.res, df_5_49.model1.fit)
                    
# ARIMA(1,1,0)(1,1,0)[12]
df_5_49.model2 <- arima(df_5_49.ts, order=c(1,1,0), seasonal = list(order = c(1,1,0), period = 12))
df_5_49.model2.res <- as.vector(residuals(df_5_49.model2))
df_5_49.model2.fit <- as.vector(fitted(df_5_49.model2))
df_5_49.model2.aic <- aic_J(df_5_49.model2, df_5_49.ts) # 4410
analyze_residuals(df_5_49.model2.res, df_5_49.model2.fit)

# ARIMA(0,1,1)(0,1,1)[12]
df_5_49.model3 <- arima(df_5_49.ts, order=c(0,1,1), seasonal = list(order = c(0,1,1), period = 12))
df_5_49.model3.res <- as.vector(residuals(df_5_49.model3))
df_5_49.model3.fit <- as.vector(fitted(df_5_49.model3))
df_5_49.model3.aic <- aic_J(df_5_49.model3, df_5_49.ts) # 4356
analyze_residuals(df_5_49.model3.res, df_5_49.model3.fit)

# ARIMA(2,1,0)(0,1,1)[12]
df_5_49.model4 <- arima(df_5_49.ts, order=c(2,1,0), seasonal = list(order = c(0,1,1), period = 12))
df_5_49.model4.res <- as.vector(residuals(df_5_49.model4))
df_5_49.model4.fit <- as.vector(fitted(df_5_49.model4))
df_5_49.model4.aic <- aic_J(df_5_49.model4, df_5_49.ts) # 4356
analyze_residuals(df_5_49.model4.res, df_5_49.model4.fit) 


plot(df_5_49$yt, type = "l")
#lines(df_5_49.model1.fit, col = "green") 
#lines(df_5_49.model2.fit, col = "red") 
lines(df_5_49.model3.fit, col = "blue") # best
#lines(df_5_49.model4.fit, col = "orange") 

get.best.sarima(df_5_49.ts) # 0 1 1 0 1 1

