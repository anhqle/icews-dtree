# load data
icews = read.csv("icews-agg.csv", header=T, as.is=TRUE)
dim(icews)

mids = read.csv("dyad_month_MID_post1990.csv", header=T, as.is=TRUE)
dim(mids)
cat("loaded\n")

merged = merge(icews, mids, by.x=c("source", "target", "year", "month"), 
  by.y=c("stateA", "stateB", "year", "month"),
  all.x=TRUE, all.y=TRUE)
cat("merged\n")
dim(merged)

head(merged)

merged = merged[order(merged$source, merged$target, merged$year, merged$month),]
head(merged)
tail(merged)
length(which(merged$year==2013))

save(merged, file="merged.rda")
write.csv(merged, file="merged.csv",
  quote=FALSE,
  append=TRUE,
  col.names=FALSE,
  row.names=FALSE)
cat("saved\n")
