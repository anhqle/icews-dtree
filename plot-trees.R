
# load trees
load("data.rda")
load("yhat.rda")
load("yobs.rda")

load("test.rda")
load("tree_mine.rda")
load("tree_mine_pruned.rda")


summary(tree_mine)
prp(tree_mine)

# out-of-sample performance


splitlabs = function(x, labs, digits, varlen, faclen){
  tmp = gsub("event1", "Statement",     labs)
  tmp = gsub("event2", "Appeal",        tmp)
  tmp = gsub("event3", "IntentCoop",    tmp)
  tmp = gsub("event4", "Consult",       tmp)
  tmp = gsub("event5", "Diplomatic",    tmp)
  tmp = gsub("event6", "MaterialCoop",  tmp)
  tmp = gsub("event7", "Aid",           tmp)
  tmp = gsub("event8", "Yield",         tmp)
  tmp = gsub("event9", "Investigate",   tmp)
  tmp = gsub("event10", "Demand",       tmp)
  tmp = gsub("event11", "Disapprove",   tmp)
  tmp = gsub("event12", "Reject",       tmp)
  tmp = gsub("event13", "Threaten",     tmp)
  tmp = gsub("event14", "Protest",      tmp)
  tmp = gsub("event15", "Force",        tmp)
  tmp = gsub("event16", "Reduce",       tmp)
  tmp = gsub("event17", "Coerce",       tmp)
  tmp = gsub("event18", "Assault",      tmp)
  tmp = gsub("event19", "Fight",        tmp)
  tmp = gsub("event20", "Violence", tmp)
  # tmp = gsub("quad2p", "Material Coop (\\%)", tmp, fixed=TRUE)
  return(tmp)
}
nodelabs = function(x, labs, digits, varlen){
  # tmp = gsub("0.", ".", labs, fixed=TRUE)
  tmp = sub("0.", ".", labs, fixed=TRUE)
  # tmp = sub(c("0", "1"), c("Peace", "War"), tmp, fixed=TRUE)
  # tmp = sub("1", "War", tmp, fixed=TRUE)
  # tmp = sub(".War", ".1", tmp, fixed=TRUE)
  # tmp = sub(".0War", ".01", tmp, fixed=TRUE)
  # tmp = sub("1", "War", tmp)
  return(tmp)
}


red = rgb(252, 141, 89, maxColorValue=255)
green = rgb(145, 207, 96, maxColorValue=255)

prp(tree_mine_pruned, extra=7,
  node.fun=nodelabs, 
  split.fun=splitlabs,
  xcompact=TRUE, 
  ycompact=TRUE,
  box.col=c(green, red)[tree_mine_pruned$frame$yval])
legend("topright", pch=16, col=c(green, red), 
  legend=c("Peace", "War"),
  inset=.1)

yhat_test = predict(tree_mine_pruned, type='class', newdata=test)
yobs_test = test$hostile4
sum(as.numeric(yhat_test!=yobs_test))/sum(yobs_test) # 1.008


pathGraphics = "~/github/cs571/graphics"
setwd(pathGraphics)

tikz('tree.tex', standAlone = FALSE, width=4, height=6)
prp(tree_mine_pruned, extra=7,
  node.fun=nodelabs, 
  split.fun=splitlabs,
  xcompact=TRUE, 
  ycompact=TRUE,
  box.col=c(green, red)[tree_mine_pruned$frame$yval])
legend("topright", pch=16, col=c(green, red), 
  legend=c("Peace", "War"),
  inset=c(.1, .2))
dev.off()


#### compare tree to other models
mse = function(est, obs){
  err = obs - est
  sq.err = err^2
  mean.sq.err = mean(sq.err, na.rm=TRUE)
  return(mean.sq.err)
}

# misclass = function(est, obs){
#   sum(as.numeric(est!=obs))/length(obs)
# }

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
yobs = train$hostile4
# null model (all zeroes)
zeroes = rep(0, length(yobs))
mse(zeroes, yobs)
precision(zeroes, yobs)
recall(zeroes, yobs)

# glm
form_mine = as.formula(hostile4 ~ actorMIL + 
  quad1p.l1 + quad2p.l1 + quad3p.l1 + quad4p.l1 +
  event1.d1 + event2.d1 + event3.d1 + event4.d1 + event5.d1 + 
  event6.d1 + event7.d1 + event8.d1 + event9.d1 + event10.d1 +
  event11.d1+ event12.d1+ event13.d1+ event14.d1+ event15.d1 +
  event16.d1+ event17.d1+ event18.d1+ event19.d1+ event20.d1 )
glmfit = glm(form_mine, data=train, family=binomial(link=logit))
summary(glmfit)

probpred = predict(glmfit, type='response')
ypred = ifelse(probpred>0.05, 1, 0)
mse(ypred, yobs)
mse(probpred, yobs)
precision(ypred, yobs)
recall(ypred, yobs)

# tree
yhat = as.numeric(predict(tree_mine, type='class'))-1

mse(yhat, yobs)
precision(yhat, yobs)
recall(yhat, yobs)

# length(which(yhat==0 & yobs==1))
# sum(as.numeric(yhat!=yobs)) 
# sum(yobs)
# sum(as.numeric(yhat!=yobs))/sum(yobs) # 0.889


## test set
yobs = test$hostile4

# null model
zeroes = rep(0, length(yobs))

mse(zeroes, yobs)
precision(zeroes, yobs)
recall(zeroes, yobs)

# glm
probpred = predict(glmfit, type='response', newdata=test)
ypred = ifelse(probpred>0.05, 1, 0)
mse(ypred, yobs)
mse(probpred, yobs)
precision(ypred, yobs)
recall(ypred, yobs)

# tree
yhat = as.numeric(predict(tree_mine_pruned, type='class', newdata=test))-1
summary(yhat)
mse(yhat, yobs)
precision(yhat, yobs)
recall(yhat, yobs)

nrow(train)
nrow(test)

