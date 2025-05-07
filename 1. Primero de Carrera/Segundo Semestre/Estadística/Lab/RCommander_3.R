
load("C:/Users/uo299874/Desktop/RComander/Steel.RData")
library(abind, pos=16)
library(e1071, pos=17)
numSummary(Steel[,"consumption", drop=FALSE], groups=Steel$breakdowns, statistics=c("mean", "sd", "IQR", 
  "quantiles"), quantiles=c(0,.25,.5,.75,1))
Steel2 <- subset(Steel, subset=consumption > 150)

