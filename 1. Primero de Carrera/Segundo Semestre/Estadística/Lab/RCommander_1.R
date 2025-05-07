data = c(1.6, 1.7, 1.8, 1.56)
data * 100 
average = function(x){sum(x) / length(x)}
average(data)
editDataset(Dataset)
load("C:/Users/uo299874/Downloads/Steel.RData")
5*5 #Comentario
editDataset(Steel)
summary(Dataset)
summary(Steel)
library(abind, pos=16)
library(e1071, pos=17)
numSummary(Steel[,"consumption", drop=FALSE], statistics=c("mean", "sd", "IQR", "quantiles"), quantiles=c(0,.25,.5,.75,1))
local({
  .Table <- with(Steel, table(breakdowns))
  cat("\ncounts:\n")
  print(.Table)
  cat("\npercentages:\n")
  print(round(100*.Table/sum(.Table), 2))
})


# Sesions: Descriptive Statistics
# Goal: To summarise data
# Types of variables:
# - Qualitative: (Not numbers)
# 	- Categorical
# 	- Ordinal
#
# - Quantitative: (Numbers)
# 	- Discrete: To Qualitative -> Data > Manage > Convert > Use numbers
# 	- Continuous: To Qualitative -> Data > Manage > Recode
# 		- Recode -
# 		Recode directives: In each line for example lo:100 = "Low" \n 101:hi = "High"   Para el primero [ , ] pal resto ( , ]
# 	Operaciones columnas: Data > Manage > Compute new variables
#
# 1- Frequency: Statistics > Summaries > Freq. Dist
# 2- General Summary: Statistics > Summaries > Active Data Set
# 3- Numerical Summary: Statistics > Summaries > Numerical Summaries > Statistics (Para más precisión)
#
# Filters: Data > Active > Subset active data set:
# 	Name for new: El nombre que quieras
# 	Subset expresion: <nombre variable><expresión(==, !=, <, >, >=, <=)><value(if numero tal cual hermano, "qualitative", entre comillas)> (Opcional: & -> AND, | -> OR) Y ahora otra expresión
# 	Ex: consumption>=100&temperature=="Low" (Respetar mayúsculas)
#	(<> se quita)
#
# Distributions:
# 	- From a Distribution in the menu:
# 	r<distribution>(<number of values>,<parameters of distribution>)
# 	Ex: rexp(250,4) -> mean(rexp(250,4)) -> 1/4
#
# 	- From a Distribution NOT in the menu:
# 	sample(<values[array]>,<number of observations>,<probability[array]>,replace=TRUE)      (replace=TRUE Sirve para tener siempre la misma probabilidad)
# 	to create an array: c(valor,...,valor)
# 	Ex: sample(c(100,1,-2),1000,c(0.01,0.1,0.89),replace=TRUE) -> sum(sample(c(100,1,-2),1000,c(0.01,0.1,0.89),replace=TRUE))
#	
# 	- Discrete Distribution: 
# 	1- Binomial Distribution:
# 		P(X<=k) = p
# 		1. I know k and want p: Binomial tail prob: (Lower Tail : <= - Upper Tail: >) <[)>     (Variable Value is the k)!! Si quieres hacer varias <= o > de una, valores con comas
# 		2. I know k and want p, but x=k: Binomial probabilities: Te devuelve una tabla, donde miraré el valor (Probs < 0.0001 No se representan)
# 		3. I know p and want k: Binomial quantiles:                                       (Probabilities is the value p)!!
# 	2- Poisson: Igual solo que tiene el valor mean
#
# 	Si necesitamos P(X<k) = P(X<= k-1) y P(X>=k) = P(X>k-1) !! si usamos el quantile, recordar sumar 1 si sucele lo anterior
#
# 	at least : >=  -  at most : <=  -  less than : <  -  more than : >  -  exactly : = (2. x=k)
#
# 	- Continuous Distribution:
# 	1. Normal Distribution: Plot density -> La de relative frequency, y plot Distribution -> Cumulative freq.
# 		P(X<=k) = p
# 		1. I know k and want p: Normal probabilities: (Lower Tail : < - Upper Tail: >)
# 		2. I know p and want k: Normal quantiles: (P(exp(1)<= k)) = 0,6
# 	2. Exponential
# 	3. Weibul: pweibull(c(1,3), shape=2, scale=3, lower.tail=TRUE)
# 	
# 	
#
# Save output

