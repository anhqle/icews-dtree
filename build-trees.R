# setup
library(rpart)
library(rpart.plot)   # Enhanced tree plots


# load data
getwd()
full_data = read.csv("merged.csv", as.is=TRUE)
dim(full_data)
names(full_data)
data = full_data[full_data$year<=2005,]
test = full_data[full_data$year> 2005,]
dim(data)

# compute helper variables
names(data)
data$hostile4
data$hostlevA = ifelse(is.na(data$hostlevA), 0, data$hostlevA)
data$hostlevB = ifelse(is.na(data$hostlevB), 0, data$hostlevB)
summary(data$hostlevA)
summary(data$hostlevB)
data$hostile4 = 0
data$hostile4[data$hostlevA>=4] = 1
data$hostile4[data$hostlevB>=4] = 1
summary(data$hostile4)


# modeling

form_mine = as.formula(hostile4 ~
  event1 + 
  event2 + 
  event3 + 
  event4 + 
  event5 + 
  event6 + 
  event7 + 
  event8 + 
  event9 + 
  event10 + 
  event11 + 
  event12 + 
  event13 + 
  event14 + 
  event15 + 
  event16 + 
  event17 + 
  event18 + 
  event19 +
  event20
)

ctrl = rpart.control(cp=1e-4)
start = Sys.time()
tree_mine = rpart(form_mine, data=data, 
  method='class', control=ctrl,
  parms=list(split='gini'))
runtime = Sys.time() - start
runtime





# in-sample performance
tree_mine
summary(tree_mine)
printcp(tree_mine)
prp(tree_mine)

yhat = predict(tree_mine, type='class')
yobs = data$hostile4[as.numeric(names(yhat))]
yobs = ifelse(is.na(yobs), 0, yobs)
yhat = as.numeric(yhat) - 1
summary(yhat)
summary(yobs)
save(yhat, file="yhat.rda")
save(yobs, file="yobs.rda")


length(yobs)
length(which(yhat==0 & yobs==1))
sum(as.numeric(yhat!=yobs)) 
sum(yobs)
sum(as.numeric(yhat!=yobs))/sum(yobs) # 0.889


yhat = predict(tree_mine_pruned, type='class')
sum(as.numeric(yhat!=yobs))/sum(yobs) # 0.983


# out-of-sample performance

# prune to minimize test error 
tree_mine_pruned = prune(tree_mine, cp=printcp(tree_mine)[3] )
printcp(tree_mine_pruned)
prp(tree_mine_pruned)

yhat_test = predict(tree_mine_pruned, type='class', newdata=test)
yobs_test = test$hostile4
sum(as.numeric(yhat_test!=yobs_test))/sum(yobs_test) # 1.008

# see plot-trees.R, etc 