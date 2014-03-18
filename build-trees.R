# setup
library(rpart)
library(rpart.plot)   # Enhanced tree plots


# load data
getwd()
full_data = read.csv("merged.csv", as.is=TRUE)
dim(full_data)
names(full_data)

# compute helper variables
names(full_data)
full_data$hostlevA = ifelse(is.na(full_data$hostlevA), 0, full_data$hostlevA)
full_data$hostlevB = ifelse(is.na(full_data$hostlevB), 0, full_data$hostlevB)
summary(full_data$hostlevA)
summary(full_data$hostlevB)
full_data$hostile4 = 0
full_data$hostile4[full_data$hostlevA>=4] = 1
full_data$hostile4[full_data$hostlevB>=4] = 1
summary(full_data$hostile4)

# split into training and test sets
data = full_data[full_data$year<=2005,]
test = full_data[full_data$year> 2005,]
dim(data)
dim(test)

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

# build trees 
ctrl = rpart.control(cp=1e-4)
start = Sys.time()
tree_mine = rpart(form_mine, data=data, 
  method='class', control=ctrl,
  parms=list(split='gini'))
runtime = Sys.time() - start
runtime

tree_mine
summary(tree_mine)
printcp(tree_mine)
prp(tree_mine)


tree_mine_pruned = prune(tree_mine, cp=printcp(tree_mine)[2] )
prp(tree_mine_pruned)

save(tree_mine, file="tree_mine.rda")
save(tree_mine_pruned, file="tree_mine_pruned.rda")


# in-sample performance
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
sum(as.numeric(yhat!=yobs))/sum(yobs) # 1.012


yhat = predict(tree_mine_pruned, type='class')
yhat = as.numeric(yhat) - 1
head(yhat)
summary(yhat)
sum(as.numeric(yhat!=yobs))/sum(yobs) # 1.009


# out-of-sample performance

yhat_test = as.numeric(predict(tree_mine_pruned, type='class', newdata=test))-1
yobs_test = test$hostile4
sum(as.numeric(yhat_test!=yobs_test))/sum(yobs_test) # 1.31

# see plot-trees.R, etc 