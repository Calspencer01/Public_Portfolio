get_AICs <- function(ts, param_list, seasonal_period){
  AICs <- c()
  for (params in param_list) {
    model <- Arima(ts, order=c(params[1],params[2],params[3]), seasonal = list(order=c(params[4],params[5],params[6]), period = seasonal_period))
    model.aic <- aic_Jha(model, ts) 
    print(model.aic)  
    AICs <- c(AICs, model.aic)
  }
  return (AICs)
}


# Dr Jha's AIC function
aic_Jha <- function(model, series){
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