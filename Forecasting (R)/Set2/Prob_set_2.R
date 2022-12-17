############################
##      Problem set 2     ##
##     Calvin Spencer     ##
############################

rm(list=ls())   #Clean workspace
getwd()         #Get current working directory
setwd("C:/Users/calvinspencer/Desktop/Forecasting") #Set working directory


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




#install.packages(c("tidyverse", "zoo", "ggplot2", "qcc"))   #Install necessary packages
library(ggplot2)
library(tidyverse)  #Load packages: tidyverse
library(zoo)        #Load packages: zoo
library(dplyr)
library(qcc)

# 3.1 ----
df_3_1 <- read.csv("E3.1.csv") %>%
  mutate(Year = as.numeric(Year)) %>%
  mutate(Days = as.numeric(Days)) %>%
  mutate(Index = as.numeric(Index))

df_3_1.fit_index  <- lm(Days ~ Index, data = df_3_1)
df_3_1.fit_intercept_coeff <- df_3_1.fit_index$coefficients[1]
df_3_1.fit_index_coeff <- df_3_1.fit_index$coefficients[2]

df_3_1.fit_index_pts <-  df_3_1 %>%
  dplyr::mutate(Fit = df_3_1.fit_index$fit)


par(mfrow=c(1,1))
plot(df_3_1$Index, df_3_1$Days, pch=16, xlab='Seasonal meteorological index', ylab='Days the ozone levels exceeded 0.20 ppm')
lines(df_3_1.fit_index_pts$Index, df_3_1.fit_index_pts$Fit, col = "red")

summary(df_3_1.fit_index)

# Significance of regression: t value: -0.290 for Index coefficient has a P-value of 0.776, which is far too high for the meteorological index to be statistically significant in this model. This value tells us that there is over a 77% chance that these results are due to random variation

new_obs <- data.frame(Index = 17)
df_3_1.fit_index.pred1.ci <- predict(df_3_1.fit_index, newdata=new_obs, se.fit = TRUE, interval = "confidence")
df_3_1.fit_index.pred1.pi <- predict(df_3_1.fit_index, newdata=new_obs, se.fit = TRUE, interval = "prediction")

# Confidence interval: fit      lwr      upr
#                      8.172431 5.509336 10.83553

#Prediction Interval: fit       lwr      upr
#                     8.172431 -1.555051 17.89991

# Confidence: 95% of confidence intervals made will contain the true mean

#Interpret these quantities
# Confidence interval is a range roughly 5 units wide that the model expects 95% of future predictions to fall within
# Prediction interval is a range roughly 20 units wide that the the model expects the prediction to fall within 95% of the time this prediction is made. This is larger than the confidence interval because the PI accounts for individual variability of variables, not just the data's mean.

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

analyze_residuals(df_3_1.fit_index$res, df_3_1.fit_index$fit)
acf(df_3_1.fit_index$res, lag.max = length(df_3_1.fit_index$res), type="correlation", main="ACF of Meteorological Index")



#f. Is there any evidence of autocorrelation in the residuals?
#install.packages("car")
library(car)
summary(df_3_1.fit_index)
dwt(df_3_1.fit_index$fit, alternative="positive")

#DWT of 0.003373387 indicates positive first order autocorrelation in the residual data
# http://berument.bilkent.edu.tr/DW.pdf


# 3.12 ----
df_3_12 <- read.csv("E3.12.csv") %>%
  mutate(t = as.numeric(t)) %>%
  mutate(xt = as.numeric(xt)) %>%
  mutate(yt = as.numeric(yt)) %>%
  select(t, xt, yt)

df_3_12.fit <- lm(yt ~ xt, data = df_3_12)

plot(df_3_12$t, df_3_12.fit$res, pch=16, 
     xlab='Month Index', ylab='Residual')
abline(h=0)
# The residuals appear to be positively autocorrelated because positive residuals tend to be followed by more positive residuals, and vice versa. 


df_3_12.fit.dwt <- dwt(df_3_12.fit$res, alternative="positive")
# The results border on inconclusive and first order positive autocorrelation because D-W stat is 1.142179 but upper and lower bounds are [1.13 - 1.38]
# http://berument.bilkent.edu.tr/DW.pdf


library(orcutt)


#' Cochrane-Orcutt does not always work properly.
#'  A major reason is that when the error terms 
#'  are positively autocorrelated, the estimate r
#'   in (12.22) tends to underestimate the 
#'   autocorrelation parameter ρ. When this bias
#'  is serious, it can significantly reduce the
#'  effectiveness of the Cochrane-Orcutt approach.

df_3_12.orcutt_fit <- cochrane.orcutt(df_3_12.fit, max.iter = 1) # Does not converge
df_3_12.orcutt_full_fit <- cochrane.orcutt(df_3_12.fit)

summary(df_3_12.fit)
#summary(df_3_12.orcutt_fit)
summary(df_3_12.orcutt_full_fit)

# Least Squares Regression
# Intercept: -1.149332
# xt: 0.290784

# Cochrane Orcutt Regression (Converged)
# Intercept: -1.177609
# xt: 0.295206

df_3_12.orcutt_fit$number.interaction #Should be 1
df_3_12.orcutt_fit$rho # 0.41 indicates there is not much autocorrelation in the data

df_3_12.orcutt_fit.dwt <- dwt(df_3_12.orcutt_fit$res, alternative="positive")
# DW stat of 1.954151 indicates that there is no evidence of positive autocorrelation because it exceeds the upper bounds of 1.38


#3.13 ----
df_3_13 <- df_3_12
df_3_13$yt1 <- df_3_13$yt - lag(df_3_13$yt, 1)
df_3_13$xt1 <- df_3_13$xt - lag(df_3_13$xt, 1)

df_3_13.fit <- lm(yt1 ~ 0 + xt1, data = df_3_13)
# xt1 coefficient: 0.2976 
# cochrane orcutt converged xt coefficient: 0.295206
# OLS xt coefficient: 0.290784

#3.35 ----
df_3_35 <- read.csv("B20.csv") %>%
  mutate(Year = as.numeric(Year)) %>%
  mutate(Refund = as.numeric(Refund)) %>%
  mutate(Population = as.numeric(Population)) %>%
  select(Year, Refund, Population)


df_3_35.fit <- lm(Refund ~ Population, data = df_3_35)

df_3_12.fit.dwt <- dwt(df_3_35.fit$res, alternative="positive")

analyze_residuals(df_3_35.fit$res, df_3_35.fit$fit)
# Residual plot shows that residuals deviate too much on the tails of the data
# Histogram shows that the residuals are not very equally distributed; there is a tail toward the left. 
# Residuals appear to be correlated with the fitted value of the second plot, showing that errors are autocorrelated

df_3_35$yt1 <- df_3_35$Refund - lag(df_3_35$Refund, 1)
df_3_35$xt1 <- df_3_35$Population - lag(df_3_35$Population, 1)

df_3_35.fit_3119 <- lm(Refund ~ (yt1 + Population + xt1), data = df_3_35)
df_3_35.fit_3120 <- lm(Refund ~ (yt1 + Population), data = df_3_35)

summary(df_3_35.fit) #SE 24030 
summary(df_3_35.fit_3119) #SE 22570
summary(df_3_35.fit_3120) #SE 22320

# 3.36 ----
df_3_36 <- read.csv("B25.csv") %>%
  mutate(Year = as.numeric(Year)) %>%
  mutate(Fatalities = as.numeric(Fatalities)) %>%
  mutate(Drivers = as.numeric(Drivers)) %>%
  mutate(Vehicles = as.numeric(Vehicles)) %>%
  mutate(Miles = as.numeric(Miles)) %>%
  mutate(Unemployment = as.numeric(Unemployment)) %>%
  select(Year, Fatalities, Drivers, Vehicles, Miles, Unemployment)

plot(df_3_36$Year, df_3_36$Fatalities, pch=16, 
     xlab='Year', ylab='Fatalities')
plot(df_3_36$Drivers, df_3_36$Fatalities, pch=16, 
     xlab='Drivers', ylab='Fatalities')
plot(df_3_36$Vehicles, df_3_36$Fatalities, pch=16, 
     xlab='Vehicles', ylab='Fatalities')
plot(df_3_36$Miles, df_3_36$Fatalities, pch=16, 
     xlab='Miles', ylab='Fatalities')
plot(df_3_36$Unemployment, df_3_36$Fatalities, pch=16, 
     xlab='Unemployment', ylab='Fatalities')

df_3_36.drivers_fit <- lm(Fatalities ~ Drivers, data = df_3_36)
summary(df_3_36.drivers_fit)
analyze_residuals(df_3_36.drivers_fit$res, df_3_36.drivers_fit$fit)

df_3_36.drivers_fit.dwt <- dwt(df_3_36.drivers_fit$res, alternative="positive")

# 3.37 ----
df_3_37 <- df_3_36
df_3_37.vehicles_drivers_fit <- lm(Fatalities ~ (Drivers + Vehicles), data = df_3_37)

summary(df_3_37.vehicles_drivers_fit)
analyze_residuals(df_3_37.vehicles_drivers_fit$res
                  , df_3_37.vehicles_drivers_fit$fit)
df_3_37.vehicles_drivers_fit.dwt <- dwt(df_3_37.vehicles_drivers_fit$res, alternative="positive")

# DWT is now higher, so there is less autocorrelation, probably because we are including a factor that likely depends on time
# Residuals still deviate on the QQ plot, however, overall the distributions of residuals seem more randomly distributed around a centered mean


# 3.38 ----
#http://www.sthda.com/english/articles/37-model-selection-essentials-in-r/154-stepwise-regression-essentials-in-r/
library(leaps)
df_3_38 <- df_3_37
df_3_38.step_fit  <- lm(Fatalities ~ Year + Vehicles + Unemployment, data=df_3_38)
df_3_38.step_fit.both <- step(df_3_38.step_fit, direction='both')

summary(df_3_38.step_fit.both)
#R-squared: 0.6157


# 3.39 ----
df_3_39 <- df_3_37
df_3_39.step_fit.best <- regsubsets(Fatalities ~ Year + Drivers + Vehicles + Miles + Unemployment, data=df_3_39)
summary(df_3_39.step_fit.best)[2]  # find r-squares
# Best R-squared: 0.753951551









