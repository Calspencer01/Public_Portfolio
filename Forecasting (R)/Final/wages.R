library(ggplot2)
library(tidyverse)  #Load packages: tidyverse
library(zoo)        #Load packages: zoo
library(stats)
library(forecast)
library(dplyr)

source("helpers.R", local = TRUE)

# Load in data
df_wages <- read.csv("wage_data/weekly_wage.csv") %>%
  dplyr::rename(date = DATE, CPI_wage = LEU0252918500Q)

# 84 instances
df_wages.len <- nrow(df_wages)

# Positions of sample data within dataset
train_indeces <- 1:(ceiling(df_wages.len*0.8))

# Positions of in sample forecasts within dataset
in_forecast <- (ceiling(df_wages.len*0.8)+1):df_wages.len

# Time series object for in sample forecasts
df_wages.ts <- ts(df_wages$CPI_wage[train_indeces]
                      , start = c(2000, 1)
                      , frequency = 4)

# Time series object for out of sample forecasts
df_wages.ts_full <- ts(df_wages$CPI_wage
                           , start = c(2000, 1)
                           , frequency = 4)

# Graphing time series ----
par(cex = 0.5)
plot(df_wages.ts, ylim = c(800, 1400), type = "p")
title("Quarterly median usual weekly nominal earnings")


# Analyze ACF & PACF ----
acf_plot(df_wages.ts, max_lag = 40, title = "quarterly median usual weekly nominal earnings")

# Making Data Stationary ----
print("First Difference")
diff1 <- diff(df_wages.ts, lag = 1)
plot(diff1)
acf_plot(diff1, max_lag = 40, title = "first difference") 
# Appears like there is second/third order autoregression

print("Second Difference")
diff2 <- diff(diff1, lag = 1)
plot(diff2)
acf_plot(diff2, max_lag = 40, title = "second difference")
# MA 1, AR 2

print("Seasonal Difference")
diff3 <- diff(df_wages.ts, lag = 4)
plot(diff3)
acf_plot(diff3, max_lag = 40, title = "seasonal difference")
# First order AR & first order MA


# Test initial possibilities
scores <- get_AICs(df_wages.ts
                   , list(c(0,0,0,1,1,2)
                          , c(1,1,0,1,1,1)
                          , c(0,1,1,1,1,1) # 528
                          , c(1,1,1,1,1,1) # 533.3899
                          , c(1,1,0,1,1,1)
                          , c(0,1,0,0,1,1)
                          , c(0,1,0,1,1,0))
                   , seasonal_period = 4)

# Model Data ---- 
# Using 2 methods (ARIMA, GARCH, or Exponential Smoothing)

model <- Arima(df_wages.ts, order=c(0,1,1), seasonal = list(order = c(1,1,1), period = 4))
model.fit <- as.vector(fitted(model))
model.res <-  as.vector(residuals(model))
model.aic <- aic_Jha(model, df_wages.ts) 
model.aic

model2 <- Arima(df_wages.ts, order=c(1,1,1), seasonal = list(order = c(1,1,1), period = 4))
model2.fit <- as.vector(fitted(model2))
model2.res <-  as.vector(residuals(model2))
model2.aic <- aic_Jha(model2, df_wages.ts) 
model2.aic

#Garch ---- 
# model.garch <- garch(model.res, trace = F)
# t(confint(model.garch))
# 
# model.garch.res <- resid(model.garch)[-1]
# model.garch.fit <- model.fit[2:length(model.fit)]
# 
# acf(model.garch.res)
# analyze_residuals(model.garch.res, model.garch.fit)


# Analysis ----
# If using Arima do visual analysis and auto-Arima function

# Plot possible models
par(cex = 0.5)
plot(df_wages$CPI_wage, ylim = c(800, 1600), type = "p")
title("Modeling qarterly median usual weekly nominal earnings")
lines(model.fit, col = "purple")

get.best.sarima(df_wages.ts, maxord = rep(1,6))
get.best.sarima(df_wages.ts, maxord = rep(2,6))

# Residual Analysis ----
acf_plot(model.res, title = "Model 1 residuals")
analyze_residuals(model.res, model.fit) # Best

acf_plot(model2.res, title = "Model 2 residuals")
analyze_residuals(model2.res, model2.fit)

# Metrics ----
print(model.aic) # Best
accuracy(model)

print(model2.aic)
accuracy(model2)

# DW Test? TODO

# In sample forecasts ----

# Create object for forecasts, select model to use
forecast_model_in <- model

# Vectors to be filled with forecasts
forecast_model_in.mean <- NULL
forecast_model_in.lower <- NULL
forecast_model_in.upper <- NULL

forecast_model_in.data <- df_wages$CPI_wage[train_indeces]

# For each index in the in-sample forecasts, make a one-year ahead prediction
for (h1 in 1:length(in_forecast)){
  new_forecasts <- forecast(forecast_model_in, h = 4)
  
  forecast_model_in.mean <-  c(as.numeric(forecast_model_in.mean),  new_forecasts$mean[4])
  forecast_model_in.lower <- c(as.numeric(forecast_model_in.lower), new_forecasts[['lower']][4,2])
  forecast_model_in.upper <- c(as.numeric(forecast_model_in.upper), new_forecasts[['upper']][4,2])
  
  forecast_model_in.data <- forecast_model_in.data %>%
    c(df_wages$CPI_wage[in_forecast[h1]]) # Append next observation to model's training data
    
  forecast_model_in <- forecast_model_in.data %>%
    ts(start = 2000, frequency = 4) %>% # Convert to timeseries
    arima(order=c(0,1,1), seasonal = list(order = c(1,1,1), period = 4)) # Fit model to current data
}
par(cex = 0.5)

# Plot model with its in sample forecasts
plot(ts(df_wages$CPI_wage, start = 2000, frequency = 4), type = "p", xlim = c(2000, 2023), ylim = c(800, 1800))
title("One-year ahead in-sample forecasts of median usual weekly nominal earnings")
lines(fitted(model), col = "purple")
lines(ts(c(rep(NA, length(train_indeces)), forecast_model_in.mean),  start = 2000, frequency = 4), col = "red")
lines(ts(c(rep(NA, length(train_indeces)), forecast_model_in.lower), start = 2000, frequency = 4), col = "blue")
lines(ts(c(rep(NA, length(train_indeces)), forecast_model_in.upper), start = 2000, frequency = 4), col = "blue")

# Calculate residuals
res <- df_wages$CPI_wage[in_forecast] - forecast_model_in.mean

# Analyze reesiduals
analyze_residuals(res, forecast_model_in.mean)
acf_plot(res, title = "model residuals")


# Out of sample forecasts ----

# Create object for forecasts 
forecast_model_out <- Arima(df_wages.ts_full, order=c(0,1,1), seasonal = list(order = c(1,1,1), period = 4))

# Vectors to be filled with forecasts
forecast_model_out.mean <- NULL
forecast_model_out.lower <- NULL
forecast_model_out.upper <- NULL

steps <- 8
for (h1 in 1:steps){
  new_forecasts <- forecast(forecast_model_out, h = h1)
  
  forecast_model_out.mean <-  c(as.numeric(forecast_model_out.mean),  new_forecasts$mean[h1])
  forecast_model_out.lower <- c(as.numeric(forecast_model_out.lower), new_forecasts[['lower']][h1,2])
  forecast_model_out.upper <- c(as.numeric(forecast_model_out.upper), new_forecasts[['upper']][h1,2])
}

# Plot model and out of sample forecasts
par(cex = 0.5)
plot(ts(df_wages$CPI_wage, start = 2000, frequency = 4), type = "p", xlim = c(2000, 2023), ylim = c(800, 1800))
title("Out-of-sample forecasts of median usual weekly nominal earnings")
lines((fitted(forecast_model_out)), col = "purple")
lines(ts(c(rep(NA, df_wages.len),  forecast_model_out.mean),  start = 2000, frequency = 4), col = "red")
lines(ts(c(rep(NA, df_wages.len),  forecast_model_out.lower), start = 2000, frequency = 4), col = "blue")
lines(ts(c(rep(NA, df_wages.len),  forecast_model_out.upper), start = 2000, frequency = 4), col = "blue")
total_ts <- ts(c(fitted(forecast_model_out), forecast_model_out.mean),  start = 2000, frequency = 4)
lines(total_ts, col = "red")

window(total_ts, 2021, c(2021, 8))

