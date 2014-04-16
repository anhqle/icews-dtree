# setup
library(rpart)
library(rpart.plot)   # Enhanced tree plots


# load data
getwd()
full_data = read.csv("icews-mdp.csv", as.is=TRUE)
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
save(data, file="data-mdp.rda")
save(test, file="test-mdp.rda")

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
  event20 +
  distance +
  jointD +
  poldist
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


tree_mine_pruned = prune(tree_mine, cp=printcp(tree_mine)[3] )
prp(tree_mine_pruned)

save(tree_mine, file="tree_mine_mdp.rda")
save(tree_mine_pruned, file="tree_mine_pruned_mdp.rda")


# in-sample performance
yhat = predict(tree_mine, type='class')
yobs = data$hostile4[as.numeric(names(yhat))]
yobs = ifelse(is.na(yobs), 0, yobs)
yhat = as.numeric(yhat) - 1
summary(yhat)
summary(yobs)
save(yhat, file="yhat-mdp.rda")
save(yobs, file="yobs-mdp.rda")


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

length(which(yhat==0 & yobs==0))
length(which(yhat==0 & yobs==1))
length(which(yhat==1 & yobs==0))
length(which(yhat==1 & yobs==1))


# out-of-sample performance

yhat_test = as.numeric(predict(tree_mine_pruned, type='class', newdata=test))-1
yobs_test = test$hostile4
sum(as.numeric(yhat_test!=yobs_test))/sum(yobs_test) # 1.31

length(which(yhat_test==0 & yobs_test==0))
length(which(yhat_test==0 & yobs_test==1))
length(which(yhat_test==1 & yobs_test==0))
length(which(yhat_test==1 & yobs_test==1))




#### compare tree to other models
mse = function(est, obs){
  err = obs - est
  sq.err = err^2
  mean.sq.err = mean(sq.err, na.rm=TRUE)
  return(mean.sq.err)
}


precision = function(est, obs){
  tp = length(which(est==1 & obs==1))
  fp = length(which(est==1 & obs==0))
  (tp/(tp+fp+1e-9))
}

recall = function(est, obs){
  tp = length(which(est==1 & obs==1))
  fn = length(which(est==0 & obs==1))
  (tp/(tp+fn))
}

## training set
load("yhat-mdp.rda")
load("yobs-mdp.rda")

# null model
zeroes = rep(0, length(yobs))
mse(zeroes, yobs)
precision(zeroes, yobs)
recall(zeroes, yobs)

# glm
glmfit = glm(form_mine, data=data, family=binomial(link=logit))
summary(glmfit)

probpred = predict(glmfit, type='response')
ypred = ifelse(probpred>0.05, 1, 0)
mse(ypred, yobs)
mse(probpred, yobs)
precision(ypred, yobs)
recall(ypred, yobs)

# tree
mse(yhat, yobs)
precision(yhat, yobs)
recall(yhat, yobs)

summary(yhat)



## test set
yhat_test = as.numeric(predict(tree_mine_pruned, type='class', newdata=test))-1
summary(yhat_test)
yobs_test = test$hostile4
summary(yobs_test)

zeroes = rep(0, length(yobs_test))
mse(zeroes, yobs_test)
precision(zeroes, yobs_test)
recall(zeroes, yobs_test)

# glm
glmfit = glm(form_mine, data=test, family=binomial(link=logit))
summary(glmfit)

probpred = predict(glmfit, type='response')
length(probpred)
yobs_test_tmp = yobs_test[as.numeric(names(probpred))]
length(yobs_test_tmp)
ypred = ifelse(probpred>0.05, 1, 0)
mse(ypred, yobs_test_tmp)
mse(probpred, yobs_test_tmp)
precision(ypred, yobs_test_tmp)
recall(ypred, yobs_test_tmp)

# tree
mse(yhat_test, yobs_test)
precision(yhat_test, yobs_test)
recall(yhat_test, yobs_test)