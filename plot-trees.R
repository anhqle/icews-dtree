# set up
# setwd('~/desktop/icews-dtree')
library(tikzDevice)

# load trees
# load("data.rda")
# load("yhat.rda")
# load("yobs.rda")

# load("test.rda")
# load("tree_mine.rda")
# load("tree_mine_pruned.rda")
load("tree_mine_mdp.rda")
load("tree_mine_pruned_mdp.rda")

summary(tree_mine)
prp(tree_mine)
prp(tree_mine_pruned)

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
  tmp = gsub("event20", "Violence",     tmp)
  tmp = gsub("distance", "Distance",     tmp)
  tmp = gsub("poldist", "PolityDiff",     tmp)
  # tmp = gsub("quad2p", "Material Coop (\\%)", tmp, fixed=TRUE)
  return(tmp)
}
nodelabs = function(x, labs, digits, varlen){
  tmp = sub("0.", ".", labs, fixed=TRUE)
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
  inset=c(.1, .2))

pdf('tree-icews-polity.pdf', width=5, height=6)
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




