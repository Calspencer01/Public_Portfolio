############################
##                        ##
##      Problem set 1     ##
##                        ##
############################

# Author: Calvin Spencer
# Data Sources: B.10.xlsx, B.16.xlsx, E.21.xlsx, E.21B.xlsx
# Professor: Dr Jha
# Economics 385

rm(list=ls())   #Clean workspace
# getwd()         #Get current working directory
# setwd("C:/Users/calvinspencer/Desktop/Forecasting") #Set working directory


#install.packages(c("tidyverse", "zoo", "ggplot2", "qcc", "readxl", "dplyr"))   #Install necessary packages
library(ggplot2)
library(tidyverse)
library(dplyr)
library(zoo)
library(readxl)

# My implementation of a variogram ----
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

df_b10 <- read_excel("B.10.xlsx") %>%
  rename(Miles = `Miles (In Millions)`)



# 2.13 ----
df_miles <- df_b10
df_miles$diff <- c(array(NA, dim = c(12,1)) # Rename columns, generate the difference
                    , diff(df_miles$Miles, lag = 12))

df_miles.nr <- nrow(df_miles) #Number of rows
df_miles.tt <- 1:df_miles.nr  #1-number of rows

# Initial Plot ----
plot(df_miles.tt
     , df_miles$Miles
     , type="l"
     , xlab='Time'
     , ylab='Miles Flown in the UK (millions)'
     , xaxt='n')

axis(side = 1
     , at = seq(1, df_miles.nr, 12)
     , labels = df_miles$Month[seq(1, df_miles.nr, 12)])

points(df_miles.tt, df_miles$Miles, pch = 16, cex = .5)

#Plotting the difference at a season lag of 12 months ----
plot(df_miles.tt[12:df_miles.nr]
     , df_miles$diff[12:df_miles.nr]
     , type="l"
     , xlab='Seasonally differenced series'
     , ylab='Seasonal, d=12'
     , xaxt='n')

axis(side = 1
     , at = seq(1, df_miles.nr, 12)
     , labels = df_miles$Month[seq(1, df_miles.nr, 12)])

points(df_miles.tt, df_miles$diff, pch = 16, cex = .5)

# Plot detrended, differenced seasonal data ----
df_miles$detrended <- c(NA,diff(df_miles$diff,1))

plot(df_miles.tt[12:df_miles.nr]
     , df_miles$detrended[12:df_miles.nr]
     , type = "l"
     , xlab = 'Detrended and Seasonally differenced series'
     , ylab = 'Seasonal d=12 with Trend d=1'
     , xaxt = 'n')

axis(1
     , seq(1, df_miles.nr, 12)
     , labels = df_miles$Month[seq(1, df_miles.nr, 12)])

points(df_miles.tt, df_miles$detrended, pch=16, cex=.5)

# Autocorrelation Function ----
acf(df_miles$detrended[14:df_miles.nr], lag.max=25, type="correlation", main="ACF of Airline Miles Flown in the UK")

# Plot variogram
variogram_plot(df_miles$Miles, 25, calc_vario)



# 2.19 ---- 
df_b16 <- read_excel("B.16.xlsx", range = "Sheet1!A1:C28")

par(mfrow=c(1,2))
# Initial Plots ----
plot(df_b16$Year
     , df_b16$GDP_current
     , type="l"
     , xlab='Year'
     , ylab='GDP Current')

plot(df_b16$Year
     , df_b16$GDP_real
     , type="l"
     , xlab='Year'
     , ylab='GDP Real')
par(mfrow=c(1,1))

#Generate autocorrelation function & variogram ----
acf(df_b16$GDP_current, lag.max = nrow(df_b16), type="correlation", main="ACF of US GDP (Current Dollars)")
variogram_plot(df_b16$GDP_current, 25, calc_vario)

# Calculate first difference ----
df_b16$diff1 <- c(NA, diff(df_b16$GDP_current, 1))
df_GDP_diff <-  df_b16[-1,] #Store in new variable

# (First difference) generate autocorrelation function & variogram  ----
acf(df_GDP_diff$diff1, lag.max = nrow(df_GDP_diff), type="correlation", main="ACF of US GDP (Current Dollars)")
variogram_plot(df_GDP_diff$diff1, 25, calc_vario)



# 2.44 ----
df_e21 <- read_excel("E.21.xlsx")

# Generate autocorrelation function ----
acf(df_e21$et_1, lag.max = 40)

# Plot historgram ----
df_e21$distribution <- rnorm(df_e21$et_1)
hist(df_e21$distribution, xlab = "Error Value")

#Calculate errors ----
mean_error <- mean(df_e21$et_1)
df_e21$sq <- df_e21$et_1 * df_e21$et_1
mean_sq_error <- mean(df_e21$sq)
mean_abs_error <- mean(abs(df_e21$et_1))



# 2.51 ----
#install.packages("qcc")
library(qcc)
df_e21b <- read_excel("E.21B.xlsx")

#  Plot individuals control chart ----
qcc(df_e21b$et_1, type="xbar.one")

#  Plot moving range control chart ----
cusum(df_e21b$et_1, title='', sizes=1)
