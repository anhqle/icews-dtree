icews = read.csv("icews-agg.csv", header=T, as.is=TRUE)
mids = read.csv("dyad_month_MID_post1990.csv", header=T, as.is=TRUE)
cat("loaded\n")

merged = merge(icews, mids, by.x=c("source", "target", "year", "month"), 
  by.y=c("stateA", "stateB", "year", "month"),
  all.x=TRUE, all.y=TRUE)
cat("merged\n")

save(merged, file="merged.rda")
write.csv(merged, file="merged.csv",
  quote=FALSE,
  append=TRUE,
  col.names=FALSE,
  row.names=FALSE)
cat("saved\n")
