# get icews dyadic events
rm(list=ls())
source('dbGetEvents.R')

mids = read.csv("dyad_month_MID_post1990.csv", as.is=TRUE)
countries = sort(unique(c(mids$stateA, mids$stateB)))
print(countries)

start = "1991-01-01"
end = "2013-12-31"

dbSetup()

for(source in countries){
  print(source)
  for(target in countries){
    data = dbGetEvents(source, target, start, end)
    write.table(data, file="icews.csv", 
      sep=",",
      quote=FALSE, 
      append=TRUE, 
      col.names=FALSE, 
      row.names=FALSE)
  }
}