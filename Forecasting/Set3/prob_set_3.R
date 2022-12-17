# Problem Set 3: Calvin Spencer

#install.packages(c("tidyverse", "zoo", "ggplot2", "qcc"))   #Install necessary packages
library(ggplot2)
library(tidyverse)  #Load packages: tidyverse
library(zoo)        #Load packages: zoo
library(dplyr)
library(qcc)
library(lubridate)



# My implementation of a variogram (From problem set1) ----
#' Params: 
#'   series - Numeric vector of time series set
#'   num_k - Number of lags to plot
#'   calc_varigram - calc_variogram function 
#' Returns:
#'   vector of the same length as ks containing of variograms at each lag
variogram_plot <- function(series, num_k, calc_variogram) {
  # Build DF with lags to test
  df_variogram <- as.data.frame(1:num_k) %>%
    rename(K = paste0("1:num_k"))
  
  #Variance of lag 1
  ls_denom <- (lag(series, 1) - series)[2:length(series)]
  denom1 <- var(ls_denom)
  
  #Variance at lag K
  df_variogram[,"variogram"] <- calc_variogram(series, df_variogram$K, denom1)
  
  #Plot variance by lag
  plot(df_variogram$K, df_variogram$variogram
       , xlab='Lag (K)'
       , ylab='Variogram') %>%
    return()
}

# Variogram_plot helper fxn ----
#' Calculates variogram at specific lag (not vectorized)
#' Params: 
#'   yt - Numeric vector of time series set
#'   ks - Numeric vector of lags to plot
#'   denom - denominator of variogram ie variance at lag 1
#' Returns:
#'   vector of the same length as ks containing of variograms at each lag
calc_vario <- function(series, ks, denom){
  result <- c(0)
  for (k in ks){
    len <- length(series)
    ls_numer <- (lag(series, k) - series)[(k+1):len]
    numer <- var(ls_numer)
    result <- append(result, numer / denom, after = length(result))
  }
  return(result[2:length(result)])
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

# Dr Jha's Trigg and Leach fucntion implementation
tlsmooth <- function(y, gamma, y.tilde.start=y[1], lambda.start=1){
  T <- length(y)
  
  #Initialize the vectors
  Qt <- vector()
  Dt <- vector()
  y.tilde <- vector()
  lambda <- vector()
  err <- vector()
  
  #Set the starting values for the vectors
  lambda[1] = lambda.start
  y.tilde[1] = y.tilde.start
  Qt[1] <- 0
  Dt[1] <- 0
  err[1] <- 0
  
  for (i in 2:T){
    err[i] <- y[i] - y.tilde[i-1]
    Qt[i] <- gamma*err[i] + (1-gamma)*Qt[i-1]
    Dt[i] <- gamma*abs(err[i]) + (1-gamma)*Dt[i-1]
    lambda[i] <- abs(Qt[i]/Dt[i])
    y.tilde[i] = lambda[i]*y[i] + (1-lambda[i])*y.tilde[i-1]
  }
  return(cbind(y.tilde, lambda, err, Qt, Dt))
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
#' 
#' @param res residuals being plotted
#' @param fit fitted model

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

# # One-step ahead forecast function ----
# tau_steps <- function(la, tau, alpha, yt){
#   rows <- length(yt)
#   data <- head(yt, -tau)
#   forecasts <- data.frame(fit = rep(NA, tau)
#                           , cl = rep(NA, tau))
#   
#   hw <- HoltWinters(data, alpha = la, beta=FALSE, gamma=FALSE)
#   
#   count <- 0
#   for (i in 1:tau){
#     data <- c(head(yt, -tau), forecasts$fit[1:i-1])
#     hw <- HoltWinters(data, alpha = la, beta=FALSE, gamma=FALSE)
#     prediction <- predict(hw, 1, prediction.interval = T)
#     print(prediction[,1])
#     forecasts$fit[i] <- prediction[,1]
#     forecasts$cl[i] <- prediction[,1] - prediction[,2]
#   }
#   return(forecasts)
# }

# 1. Chapter 4 Question 1 [5] -----
# Consider the time series data shown in Table E4.1.
# 
# a. Make a time series plot of the data.
# b. Use simple exponential smoothing with 𝜆 = 0.2 to smooth the first 40 time periods of this data. How well does this smoothing procedure work?
# c. Make one-step-ahead forecasts of the last 10 observations. Determine the forecast errors.
df_4_1.data <- read.csv('set_3_data/E.4.1.csv')[1:50,] %>%
  select(period = Period, yt)

plot(df_4_1.data, type="p", pch=16, cex=.5, xlab='Period', ylab='yt', xaxt='n')
lines(df_4_1.data$yt)
axis(1, df_4_1.data$period)

df_4_1.ses <- firstsmooth(y = df_4_1.data$yt[1:40], lambda = 0.2)
lines(df_4_1.ses, col = "red")



lamb <- 0.2
i <- 1
T <- 40
tau <- 10
alpha.lev <- 0.05
df_4_1.forecast <- rep(0,tau)
df_4_1.cl <- rep(0, tau)

df_4_1.smooth1 <- rep(0,T+tau)
df_4_1.smooth2 <- rep(0,T+tau)

for (i in 1:tau) {
  df_4_1.smooth1[1:(T+i-1)] <- firstsmooth(y = df_4_1.data$yt[1:(T+i-1)], lambda = lamb)
  df_4_1.smooth2[1:(T+i-1)] <- firstsmooth(y = df_4_1.smooth1[1:(T+i-1)], lambda=lamb)
  df_4_1.forecast[i] <- (2+(lamb/(1-lamb))) * df_4_1.smooth1[T+i-1] - (1+(lamb/(1-lamb))) * df_4_1.smooth2[T+i-1]
  
  df_4_1.hat <- 2*df_4_1.smooth1[1:(T+i-1)] - df_4_1.smooth2[1:(T+i-1)]
  df_4_1.sig.est <- sqrt(var(df_4_1.data[2:(T+i-1),2]- df_4_1.hat[1:(T+i-2)]))
  df_4_1.cl[i] <- qnorm(1-alpha.lev/2)*df_4_1.sig.est
}

plot(df_4_1.data$yt[1:T], type="p", pch=16, cex=.5, xlab='Period', ylab='yt', xaxt='n', xlim=c(1,T+tau), ylim=c(35,65))
axis(1, seq(1,T+tau,24), df_4_1.data$period[seq(1,T+tau,24)])
lines(df_4_1.data$yt[1:T])
points((T+1):(T+tau), df_4_1.data$yt[(T+1):(T+tau)],cex=.5)
lines((T+1):(T+tau),df_4_1.forecast,  col = "blue")
lines((T+1):(T+tau),df_4_1.forecast+df_4_1.cl, col = "red")
lines((T+1):(T+tau),df_4_1.forecast-df_4_1.cl, col = "red")

df_4_1.errors <- df_4_1.data$yt[(T+1):(T+tau)] -  df_4_1.forecast
df_4_1.errors.MSE <- sum(df_4_1.errors * df_4_1.errors)/length(df_4_1.errors)

analyze_residuals(df_4_1.errors, df_4_1.forecast)


# 2. Chapter 4 Question 2 [3] -----
# 
# 4.2 Reconsider the time series data shown in Table E4.1.
# a. Use simple exponential smoothing with the optimum value of 𝜆 to smooth the first 40 time periods of
# this data (you can find the optimum value from Minitab). How well does this smoothing procedure work? 
# Compare the results with those obtained in Exercise 4.1.
# b. Make one-step-ahead forecasts of the last 10 observations. Determine the forecast errors.
# Compare these forecast errors with those from Exercise 4.1. How much has using the optimum value
# of the smoothing constant improved the forecasts?

lambdas <- seq(0.01, 0.99, 0.01)
df_4_1.SSE <- lambdas


df_4_1.SSE_fxn <- function(sc){measacc.fs(df_4_1.data$yt[1:40], sc)[1]}
df_4_1.SSE_vec <- sapply(lambdas, df_4_1.SSE_fxn ) #SAPPLY instead of "for" loops for computational purpose
df_4_1.opt_lambda <- lambdas[df_4_1.SSE_vec == min(df_4_1.SSE_vec)] #Optimal lambda that minimizes SSE
plot(y = df_4_1.SSE_vec, x = lambdas)
axis(1, lambdas)
#abline(v=df_4_1.opt_lambda, col = 'red')
mtext(text = paste("SSE min = ", round(min(df_4_1.SSE_vec),2), "\n lambda= ", df_4_1.opt_lambda)) #Main text on graph

lamb <- df_4_1.opt_lambda
i <- 1
T <- 40
tau <- 10
alpha.lev <- 0.05
df_4_1.forecast <- rep(0,tau)
df_4_1.cl <- rep(0, tau)

df_4_1.smooth1 <- rep(0,T+tau)
df_4_1.smooth2 <- rep(0,T+tau)

for (i in 1:tau) {
  df_4_1.smooth1[1:(T+i-1)] <- firstsmooth(y = df_4_1.data$yt[1:(T+i-1)], lambda = lamb)
  df_4_1.smooth2[1:(T+i-1)] <- firstsmooth(y = df_4_1.smooth1[1:(T+i-1)], lambda=lamb)
  df_4_1.forecast[i] <- (2+(lamb/(1-lamb))) * df_4_1.smooth1[T+i-1] - (1+(lamb/(1-lamb))) * df_4_1.smooth2[T+i-1]
  
  df_4_1.hat <- 2*df_4_1.smooth1[1:(T+i-1)] - df_4_1.smooth2[1:(T+i-1)]
  df_4_1.sig.est <- sqrt(var(df_4_1.data[2:(T+i-1),2]- df_4_1.hat[1:(T+i-2)]))
  df_4_1.cl[i] <- qnorm(1-alpha.lev/2)*df_4_1.sig.est
}

plot(df_4_1.data$yt[1:T], type="p", pch=16, cex=.5, xlab='Period', ylab='yt', xaxt='n', xlim=c(1,T+tau), ylim=c(35,65))
axis(1, seq(1,T+tau,24), df_4_1.data$period[seq(1,T+tau,24)])
lines(df_4_1.data$yt[1:T])
points((T+1):(T+tau), df_4_1.data$yt[(T+1):(T+tau)],cex=.5)
lines((T+1):(T+tau),df_4_1.forecast,  col = "blue")
lines((T+1):(T+tau),df_4_1.forecast+df_4_1.cl, col = "red")
lines((T+1):(T+tau),df_4_1.forecast-df_4_1.cl, col = "red")

df_4_1.errors <- df_4_1.data$yt[(T+1):(T+tau)] - df_4_1.forecast
analyze_residuals(df_4_1.errors, df_4_1.forecast)
df_4_1.errors.MSE <- sum(df_4_1.errors * df_4_1.errors)/length(df_4_1.errors)

# 3. Chapter 4 Question 3 [2] ----
acf(df_4_1.data$yt[1:50],lag.max=50) #ACF of the data
# Does not violate the assumption of uncorrelated errors

# 4. Chapter 4 Question 10 [5] ----
df_4_10.data <- read.csv('set_3_data/B.1.csv') %>%
  mutate(month = month
         , rate = as.numeric(rate))
df_4_10.data$i <- 1:nrow(df_4_10.data)

plot(df_4_10.data$rate, type="p", pch=16, cex=.5, xlab='Month', ylab='yt', xaxt='n')
lines(df_4_10.data$rate)
axis(1, at = seq(1, length(df_4_10.data$i), 6), labels = df_4_10.data$month[seq(1, length(df_4_10.data$i), 6)])

df_4_10.smooth <- HoltWinters(head(df_4_10.data$rate, -20), alpha = 0.2, beta=FALSE, gamma=FALSE)
lines(df_4_10.smooth$fitted[,1], col = "red")

# Appears to be overestimating regions with negative trends and underestimating regions with upward trends, 
# indicating we should try second order exponential smoothing

# 
lamb <- 0.2
tau <- 20
T <- nrow(df_4_10.data) - tau
alpha.lev <- 0.05
df_4_10.forecast <- rep(0,tau)
df_4_10.cl <- rep(0, tau)

df_4_10.smooth1 <- rep(0,T+tau)
df_4_10.smooth2 <- rep(0,T+tau)

for (i in 1:tau) {
  df_4_10.smooth1[1:(T+i-1)] <- firstsmooth(y = df_4_10.data$rate[1:(T+i-1)], lambda = lamb)
  df_4_10.smooth2[1:(T+i-1)] <- firstsmooth(y = df_4_10.smooth1[1:(T+i-1)], lambda = lamb)
  df_4_10.forecast[i] <- (2+(lamb/(1-lamb))) * df_4_10.smooth1[T+i-1] - (1+(lamb/(1-lamb))) * df_4_10.smooth2[T+i-1]


  df_4_10.hat <- 2*df_4_10.smooth1[1:(T+i-1)] - df_4_10.smooth2[1:(T+i-1)]
  df_4_10.sig.est <- sqrt(var(df_4_10.data[2:(T+i-1),2] - df_4_10.hat[1:(T+i-2)]))
  df_4_10.cl[i] <- qnorm(1-alpha.lev/2)*df_4_10.sig.est
}
plot(df_4_10.data$rate[1:T], type="p", pch=16, cex=.5, xlab='month', ylab='rate', xaxt='n', xlim=c(T/2,T+tau))
axis(1, seq(1,T+tau,24), df_4_10.data$i[seq(1,T+tau,24)])
lines(df_4_10.data$rate[1:T])
points((T+1):(T+tau), df_4_10.data$rate[(T+1):(T+tau)],cex=.5)
lines((T+1):(T+tau),df_4_10.forecast,  col = "blue")
lines((T+1):(T+tau),df_4_10.forecast+df_4_10.cl, col = "red")
lines((T+1):(T+tau),df_4_10.forecast-df_4_10.cl, col = "red")

#Forecast errors
df_4_10.forecast_errs <- df_4_10.forecast - df_4_10.data$rate[(T+1):(T+tau)]
analyze_residuals(df_4_10.forecast_errs, df_4_10.forecast)


# 5. Chapter 4 Question 11 [3]  ----

lambdas <- seq(0.01, 0.99, 0.01)
df_4_10.SSE <- lambdas


df_4_10.SSE_fxn <- function(sc){measacc.fs(df_4_10.data$rate[1:40], sc)[1]}
df_4_10.SSE_vec <- sapply(lambdas, df_4_10.SSE_fxn ) #SAPPLY instead of "for" loops for computational purpose
df_4_10.opt_lambda <- lambdas[df_4_10.SSE_vec == min(df_4_10.SSE_vec)] #Optimal lambda that minimizes SSE
plot(y = df_4_10.SSE_vec, x = lambdas)
#axis(1, lambdas)
#abline(v=df_4_1.opt_lambda, col = 'red')
mtext(text = paste("SSE min = ", round(min(df_4_10.SSE_vec),2), "\n lambda= ", df_4_10.opt_lambda)) #Main text on graph

#Overfitting by assigning extra weight to the previous forecast error: Drives SSE down but does not predict well

lamb <- df_4_10.opt_lambda
tau <- 20
T <- nrow(df_4_10.data) - tau
alpha.lev <- 0.05
df_4_10.forecast <- rep(0,tau)
df_4_10.cl <- rep(0, tau)

df_4_10.smooth1 <- rep(0,T+tau)
df_4_10.smooth2 <- rep(0,T+tau)

for (i in 1:tau) {
  df_4_10.smooth1[1:(T+i-1)] <- firstsmooth(y = df_4_10.data$rate[1:(T+i-1)], lambda = lamb)
  df_4_10.smooth2[1:(T+i-1)] <- firstsmooth(y = df_4_10.smooth1[1:(T+i-1)], lambda = lamb)
  df_4_10.forecast[i] <- (2+(lamb/(1-lamb))) * df_4_10.smooth1[T+i-1] - (1+(lamb/(1-lamb))) * df_4_10.smooth2[T+i-1]
  
  
  df_4_10.hat <- 2*df_4_10.smooth1[1:(T+i-1)] - df_4_10.smooth2[1:(T+i-1)]
  df_4_10.sig.est <- sqrt(var(df_4_10.data[2:(T+i-1),2] - df_4_10.hat[1:(T+i-2)]))
  df_4_10.cl[i] <- qnorm(1-alpha.lev/2)*df_4_10.sig.est
}
plot(df_4_10.data$rate[1:T], type="p", pch=16, cex=.5, xlab='month', ylab='rate', xaxt='n', xlim=c(T/2,T+tau))
axis(1, seq(1,T+tau,24), df_4_10.data$i[seq(1,T+tau,24)])
lines(df_4_10.data$rate[1:T])
points((T+1):(T+tau), df_4_10.data$rate[(T+1):(T+tau)],cex=.5)
lines((T+1):(T+tau),df_4_10.forecast,  col = "blue")
lines((T+1):(T+tau),df_4_10.forecast+df_4_10.cl, col = "red")
lines((T+1):(T+tau),df_4_10.forecast-df_4_10.cl, col = "red")

#Forecast errors
df_4_10.forecast_errs <- df_4_10.forecast - df_4_10.data$rate[(T+1):(T+tau)]
analyze_residuals(df_4_10.forecast_errs, df_4_10.forecast)

# 6. Chapter 4 Question 38 [5] ----
df_4_38.data <- read.csv("set_3_data/B.15.csv") %>%
  select(year, crime_rate)

plot(df_4_38.data$crime_rate)

df_4_38.SSE_fxn <- function(sc){measacc.fs(df_4_38.data$crime_rate, sc)[1]}
df_4_38.SSE_vec <- sapply(lambdas, df_4_38.SSE_fxn) #SAPPLY instead of "for" loops for computational purpose
df_4_38.opt_lambda <- lambdas[df_4_38.SSE_vec == min(df_4_38.SSE_vec)] #Optimal lambda that minimizes SSE
plot(y = df_4_38.SSE_vec, x = lambdas)
#axis(1, lambdas)
#abline(v=df_4_1.opt_lambda, col = 'red')
mtext(text = paste("SSE min = ", round(min(df_4_38.SSE_vec),2), "\n lambda= ", df_4_38.opt_lambda)) #Main text on graph

df_4_38.hw <- HoltWinters(df_4_38.data$crime_rate, beta=FALSE, gamma=FALSE)
plot(df_4_38.data$crime_rate)
lines(df_4_38.hw$fitted[,1], col = "red")

df_4_38.tl <- tlsmooth(df_4_38.data$crime_rate, 0.3)
lines(df_4_38.tl[,1], col = "blue")

df_4_38.hw.sse <- sum((head(df_4_38.data$crime_rate, -1) - df_4_38.hw$fitted[,1]) ** 2)
df_4_38.tl.sse <- sum((df_4_38.data$crime_rate - df_4_38.tl[,1]) ** 2)

# 7. Chapter 4 Question 39 [5] ----

df_4_39.data <- read.csv("set_3_data/B.16.csv") %>%
  mutate(current = as.numeric(GDP_current)
         , year = as.numeric(Year)
         , real = as.numeric(GDP_real)) %>%
  select(current, year, real)


plot(df_4_39.data$real)

df_4_39.SSE_fxn <- function(sc){measacc.fs(df_4_39.data$real, sc)[1]}
df_4_39.SSE_vec <- sapply(lambdas, df_4_39.SSE_fxn)
df_4_39.opt_lambda <- lambdas[df_4_39.SSE_vec == min(df_4_39.SSE_vec)]
plot(y = df_4_39.SSE_vec, x = lambdas)

mtext(text = paste("SSE min = ", round(min(df_4_39.SSE_vec),2), "\n lambda= ", df_4_39.opt_lambda)) #Main text on graph

df_4_39.hw <- HoltWinters(df_4_39.data$real, beta=FALSE, gamma = FALSE, seasonal="additive")
plot(df_4_39.data$real)
lines(df_4_39.hw$fitted[,1], col = "red")

df_4_39.tl <- tlsmooth(df_4_39.data$real, 0.3)
lines(df_4_39.tl[,1], col = "blue")

df_4_38.hw.sse <- sum((head(df_4_39.data$real, -1) - df_4_39.hw$fitted[,1]) ** 2)
df_4_38.tl.sse <- sum((df_4_39.data$real - df_4_39.tl[,1]) ** 2)

# 8. Chapter 4 Question 48 [5] ----
df_4_48.data <- read.csv("set_3_data/B.23.csv") %>%
  select(year, week, positive_percent)

df_4_48.data$i <- 1:nrow(df_4_48.data)

