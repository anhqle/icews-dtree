# get icews dyadic events
rm(list=ls())
source('dbGetEvents.R')

mids = read.csv("dyad_month_MID_post1990.csv", as.is=TRUE)
countries = sort(unique(c(mids$stateA, mids$stateB)))
print(countries)

seenEvents = read.csv("icews.csv", header=FALSE, as.is=TRUE)
lastSeen = seenEvents[nrow(seenEvents), ]

start = "1991-01-01"
end = "2013-12-31"

dbSetup()

blacklist = c("DRV", "RUM", "USR", "VTM", "ZAI")

for(source in countries){
  if(source<lastSeen$V2){ next; }
  if(source %in% blacklist){ next; }
  cat(source)
  cat("\n")
  for(target in countries){
    if(target==source){ next; }
    if(source==lastSeen$V2 & target<=lastSeen$V3){ next; }
    if(target %in% blacklist){ next; }
    cat(paste("\t", target, sep=""))
    cat("\n")
    data = dbGetEvents(source, target, start, end)
    write.table(data, file="icews.csv", 
      sep=",",
      quote=FALSE, 
      append=TRUE, 
      col.names=FALSE, 
      row.names=FALSE)
  }
}
