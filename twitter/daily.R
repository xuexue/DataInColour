setwd('/Users/xuexue/dataincolour/twitter')
library(ggplot2)
daily <- read.delim('data/daily.tsv', sep='\t', fill=F, header=T)

daily$dt <- as.Date(as.character(daily$date), '%Y%m%d')
qplot(data=daily, x=dt, y=new_user, geom='line')
qplot(data=daily, x=dt, y=total_user, geom='line')

daily.melted <- melt(daily[,c('dt','total_user','deleted_user',
                              'nonused_user','inactive_user')],
                     id.vars='dt')
qplot(data=daily.melted, x=dt, y=value, group=variable, 
      color=variable, geom='line')