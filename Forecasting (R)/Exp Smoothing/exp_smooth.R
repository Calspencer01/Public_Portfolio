library(ggplot2)
library(tidyverse) 
library(zoo)     
library(dplyr)
library(qcc)
library(lubridate)

# Dr Jha's first order exponential smoothing funciton
firstsmooth <- function(y, lambda, start=y[1]){
  ytilde <- y
  ytilde[1] <- lambda*y[1] + (1-lambda)*start
  for (i in 2:length(y)){
    ytilde[i] <- lambda*y[i] + (1-lambda)*ytilde[i-1]
  }
  ytilde
}

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

#10. Chapter 4 Question 52
# Table B.25 contains data from the National Highway Traffic Safety Administration
# on motor vehicle fatalities from 1966 to 2012. This data are used by a variety of 
# governmental and industry groups, as well as research organizations.
#a. Plot the fatalities data and comment on any features of the data that you see.
#b. Develop a forecasting procedure using first-order exponential smoothing. Use the
# data from 1966–2006 to develop the model, and then simulate one-year-ahead forecasts
# for the remaining years. Compute the forecasts errors. How well does this method seem to work?
#c. Develop a forecasting procedure using based on double exponential smoothing. 
# Use the data from 1966–2006 to develop the model, and then simulate one-year-ahead 
# forecasts for the remaining years. Compute the forecasts errors. 
# How well does this method seem to work in comparison to the method based on first-order exponential smoothing?

df_4_52 <- read.csv("B.25.csv") %>%
  select(year, fatalities) %>%
  mutate(year = as.numeric(year)
         , fatalities = as.numeric(fatalities))

df_4_52.ts <- ts(df_4_52$fatalities, start = 1966, frequency = 1)

plot(df_4_52.ts, type = "l")
#' Data shows a consistent downward trend with some long-term cyclical patterns
#' with periods of varying lengths. Sharp declines in fatalities tend to be followed
#' by increases to a lesser degree in the following ~5 years.
#' Additive variability with an additive trend.

df_4_52.train <- df_4_52 %>%
  filter(year <= 2006)

df_4_52.train$diff1 <- c(NA, diff(df_4_52.train$fatalities, 1))

df_4_52.train <- df_4_52.train[2:nrow(df_4_52.train),]
plot(df_4_52.train$diff1, type = "l")

lambda.vec <- c(seq(0.1, 0.9, 0.1), .95, .99)
sse.fatalities <- function(sc){measacc.fs(df_4_52.train$diff1,sc)[1]}
sse.vec <- sapply(lambda.vec, sse.fatalities)
opt.lambda <- lambda.vec[sse.vec == min(sse.vec)]
plot(lambda.vec, sse.vec, type="b", main = "SSE vs. lambda\n", xlab='lambda\n', ylab='SSE', pch=16, cex=.5)
acf_plot(df_4_52.train$diff1)


#Single exponential smoothing forecasts

plot(df_4_52$fatalities, type="p", pch=16, cex=.5, xlab='Year', ylab='Driver Fatalities', xaxt='n', xlim=c(1,T+tau), ylim = c(30000,60000))
lines(df_4_52.smooth1)

df_4_52.smooth1 <- firstsmooth(df_4_52$fatalities, lambda = 0.5)
df_4_52.smooth1.forecasts <- df_4_52.smooth1[(length(df_4_52.smooth1)-6):(length(df_4_52.smooth1)- 0)]
df_4_52.smooth1.fit <- df_4_52$fatalities[(length(df_4_52.smooth1)-6):(length(df_4_52.smooth1))]
df_4_52.smooth1.res <- df_4_52.smooth1.fit - df_4_52.smooth1.forecasts

sum(df_4_52.smooth1.res^2)
analyze_residuals(df_4_52.smooth1.fit, df_4_52.smooth1.res)

# Biased estimator, but seems to be better than double exponential smoothing


#Double exponential smoothing forecasts
lamd <- 0.5#opt.lambda # 0.2
T <- nrow(df_4_52.train)
tau <- 6
alpha.lev <- 0.05
df_4_52.forecast <- rep(0,tau)
cl <- rep(0,tau)
df_4_52.smooth1 <- rep(0,T+tau)
df_4_52.smooth2 <- rep(0,T+tau)
for (i in 1:tau) {
  #browser()
  df_4_52.smooth1[1:(T+i-1)] <- firstsmooth(y=df_4_52$fatalities[1:(T+i-1)], lambda=lamd)
  df_4_52.smooth2[1:(T+i-1)] <- firstsmooth(y=df_4_52.smooth1[1:(T+i-1)], lambda=lamd)
  df_4_52.forecast[i] <- (2+(lamd/(1-lamd)))*df_4_52.smooth1[T+i-1]- (1+(lamd/(1-lamd)))*df_4_52.smooth2[T+i-1]
  df_4_52.hat <- 2*df_4_52.smooth1[1:(T+i-1)] - df_4_52.smooth2[1:(T+i-1)]
  sig.est <- sqrt(var(df_4_52$fatalities[2:(T+i-1)]- df_4_52.hat[1:(T+i-2)]))
  cl[i] <- qnorm(1-alpha.lev/2)*sig.est
}
plot(df_4_52$fatalities, type="p", pch=16, cex=.5, xlab='Year', ylab='Driver Fatalities', xaxt='n', xlim=c(1,T+tau), ylim = c(30000,60000))
lines(df_4_52.smooth2[1:T])
points((T+1):(T+tau), df_4_52.train$fatalities[(T+1):(T+tau)],cex=.5)
lines((T+1):(T+tau),df_4_52.forecast, col = "red")
lines((T+1):(T+tau),df_4_52.forecast+cl, col = "blue")
lines((T+1):(T+tau),df_4_52.forecast-cl, col = "blue")

df_4_52.smooth2.fit <- df_4_52$fatalities[(nrow(df_4_52) - length(df_4_52.forecast)+1):(nrow(df_4_52))]
df_4_52.smooth2.res <- df_4_52.smooth2.fit - df_4_52.forecast

sum(df_4_52.smooth2.res^2)
analyze_residuals(df_4_52.smooth2.fit, df_4_52.smooth2.res)


df_4_52.smooth1 <- firstsmooth(df_4_52$fatalities, lambda = 0.5)
df_4_52.smooth2 <- firstsmooth(df_4_52.smooth1, lambda = 0.5)
plot(df_4_52$fatalities, type="p", pch=16, cex=.5, xlab='Year', ylab='Driver Fatalities', xaxt='n', xlim=c(1, 50), ylim = c(30000,60000))
lines(df_4_52.smooth1, col = "blue")
lines(df_4_52.smooth2, col = "red")

analyze_residuals((df_4_52$fatalities - df_4_52.smooth1), df_4_52$fatalities)
analyze_residuals((df_4_52$fatalities - df_4_52.smooth2), df_4_52$fatalities)

# Both models are significantly biased, but the second order ES appears to generalize the trend better,
# even though during 2006-2012, the first order method has smaller SSE in one-step ahead forecasts.







#11. Chapter 4 Question 56
# Data from the US Census Bureau on monthly domestic automo- bile manufacturing 
# hipments (in millions of dollars) are shown in Table B.28.
# a. Plot the data and comment on any features of the data that you see.
# b. Construct the sample ACF and variogram. Comment on these displays.
# c. Develop an appropriate exponential smoothing model for these
# data. Note that there is some apparent seasonality in the data.
# Why does this seasonal behavior occur?
# d. Plot the first difference of the data. Now compute the sample
# ACF and variogram for the differenced data. What impact has differencing had? Is there still some apparent seasonality in the differenced data?

df_4_56 <- read.csv("b.28.csv") %>%
  select(month = Month, asmp = auto_ship_mil_dollars) %>%
  mutate(asmp = as.numeric(asmp)) %>%
  filter(month != "")

df_4_56.ts <- ts(df_4_56$asmp, start = 1992, frequency = 12)


plot(df_4_56.ts)
# Signs of strong additive seasonality; every July is substantially lower than other seasons in the same year
# from 1992 - 2009, sales have a constant mean, then has an upward trend beginning around 2009, while the seasonal pattern continues

acf_plot(df_4_56.ts, max_lag = nrow(df_4_56)/2)
# Possible low order autoregression, no moving average structure
# Nonstationary process
# Clear evidence of seasonality at yearly lags

df_4_56.smooth <- HoltWinters(df_4_56.ts, alpha=0.1, beta= 0.1, gamma=0.9, seasonal="additive")

plot(df_4_56.ts, type="p", pch=16, cex=.5, xlab='Date', ylab='Domestic Automobile Shipment Sales', ylim = c(1000, 13000))
lines(df_4_56.smooth$fitted[,1], col = "blue")
#The seasonality apparent in the data likely occurs in July because that marks the beginning of the third financial quarter
# (I think)

analyze_residuals((df_4_56$asmp[13:nrow(df_4_56)] - df_4_56.smooth$fitted[,1]), df_4_56$asmp[13:nrow(df_4_56)])
# Not too shabby

df_4_56.diff <- ts(diff(df_4_56$asmp,1), start = 1992, frequency = 12)
plot(df_4_56.diff, type="l", pch=16, cex=.5, xlab='Date', ylab='Domestic Automobile Shipment Sales')
# Differencing has made the data stationary

acf_plot(df_4_56.diff, max_lag = nrow(df_4_56)/2)
# Seasonality is still present, no longer has a decaying ACF indicative of nonstationarity
# PACF indicates strong seasonal autoregression


acf_plot(ts(diff(diff(df_4_56$asmp,1),12), start = 1992, frequency = 12), max_lag = nrow(df_4_56)/2)
# Far better, seasonality is very strong

