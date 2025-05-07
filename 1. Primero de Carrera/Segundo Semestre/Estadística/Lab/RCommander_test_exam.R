
load("C:/Users/uo299874/Desktop/RComander/Students-modificado.RData")
library(colorspace, pos=16)
Students <- within(Students, {
  NumOfSiblings <- as.factor(Siblings)
})
with(Students, piechart(NumOfSiblings, xlab="", ylab="", main="NumOfSiblings", col=rainbow_hcl(6), 
  scale="percent"))
with(Students, Barplot(NumOfSiblings, xlab="NumOfSiblings", ylab="Frequency", label.bars=TRUE))
local({
  .Table <- with(Students, table(NumOfSiblings))
  cat("\ncounts:\n")
  print(.Table)
  cat("\npercentages:\n")
  print(round(100*.Table/sum(.Table), 2))
})
Students <- within(Students, {
  variable <- Recode(Siblings, '0:2="Few"; 2:hi="Many"', as.factor=TRUE, to.value="=", interval=":", separator=";")
})
local({
  .Table <- with(Students, table(variable))
  cat("\ncounts:\n")
  print(.Table)
  cat("\npercentages:\n")
  print(round(100*.Table/sum(.Table), 2))
})
editDataset(Students)
editDataset(Students)

