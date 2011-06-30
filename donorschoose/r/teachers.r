setwd('/Users/xuexue/dataincolour/donorschoose/r/')
library(ggplot2)
library(RColorBrewer)
source('read.in.projects.r')
source('../../utils/arrange.r')

tp_plot <- function(dim, var, keep=c(), title="", labs=c()) {
  x = melt(table_percent(dim, var)[,keep])
  return(ggplot(data=x,aes(x=dim, y=value, group=var, color=var)) +
    geom_line(size=1) + geom_point(size=2) +theme_bw() +
    opts(title=title) + labs(x=NULL, y=NULL, colour="") + 
    scale_y_continuous(formatter="percent")+
    opts(legend.direction="horizontal", legend.position="bottom",
         legend.justification="center",
         legend.key.size=unit(c(1,1),"lines")))
}
########## [[ COMPARISON ]]
teacher_subset = (projects$teacher_prefix != '' & 
                  projects$teacher_prefix != "Mr. & Mrs.")
percent_plot <- (tp_plot(projects$year,
                    factor(projects$teacher_prefix),
                    c("Mr.","Mrs.", "Ms."),
                    "      Percent Project Postings"))

raw <- melt(table(projects$teacher_prefix, projects$year)[c(1,5,6),])
colnames(raw) <- c("prefix", "year", "val")
raw_plot <- (ggplot(data=raw, aes(x=year, y=val, group=prefix, colour=prefix))+
             theme_bw() + geom_line(size=1)+ geom_point(size=2) +
             labs(x=NULL, y=NULL, colour="") +
             opts(legend.direction="horizontal", legend.position="bottom",
                  legend.justification="center",
                  legend.key.size=unit(c(1,1),"lines"),
                  title="        Project Postings"))
arrange(raw_plot, percent_plot)

########## [[ ODDS & PERCENTS ]]

#### teacher prefix
prefix <- plot.est(c(15,16), c("Mr.", "Mrs.", "Ms."),
                   "Effect on Odds of Project Completion",
                   "teacher_prefix")

pref.data <- tapply(projects$funding_status=="completed",
                    projects$teacher_prefix, mean)[c(1,5,6)]
pref.data <- data.frame(name=rownames(pref.data), val=pref.data)
pref_comp <- (ggplot(data=pref.data) + theme_bw() +
  opts(plot.margin=unit(c(0,1,0,0), "line")) +
  opts(panel.margin=unit(c(0,0,0,0), "line")) +
  geom_bar(aes(x=name, y=val, fill=val)) + 
  scale_x_discrete(limits=c("Mrs.", "Ms.", "Mr.")) +
  scale_y_continuous(formatter="percent", limit=c(0,1)) +
  xlab('') + ylab('') + opts(legend.position="none") +
  opts(title='Rate of Project Completion') +
  coord_flip() + 
  scale_fill_gradient2(low="red", mid="grey", high="steelblue"))

arrange(pref_comp, prefix)

########## [[ PROJECT TYPE ]]
plot.percents <- function(y, title, col) {
  y.m <- melt(y)
  colnames(y.m) <- c('dim', 'var', 'value')
  return(ggplot(data=y.m) + geom_tile(aes(x=dim, y=var, fill=value)) +
    geom_text(aes(x=dim, y=var, label=paste(round(100*value),'%',sep='')),
              size=3.5) + 
    scale_fill_gradient(low="white", high=col) +
    labs(x=NULL, y=NULL, colour="") +
    scale_x_discrete(expand = c(0,0)) +
    scale_y_discrete(expand = c(0,.5, 0.5), limits=colnames(y)) +
    opts(plot.margin=unit(c(0.5, 0.5, 0, 0), "lines"),
         legend.position='none', title=title)
  )
}
plot.sums <- function(dim, lim, title) {
  y <- table_percent(projects$teacher_prefix,
                     projects[,dim])[c(1,5,6),lim]
  y <- y[,sort(y[1,], index.return=T)$ix]
  return(plot.percents(y, title, "#4DAF4A"))
}
pref_resource <- plot.sums('resource_type', 1:4, "Resource Type")
pref_gr <- plot.sums('grade_level', 1:4, "Grade Level")
pref_metro <- plot.sums('school_metro', c(1,3,4), "School Metro")
pref_pov <- plot.sums('poverty_level', 1:4, "Poverty Level")
pref_sub <- plot.sums('primary_focus_area', 1:7, "Primary Focus Area")
pref_sub2 <- plot.sums('secondary_focus_area', 2:8, "Secondary Focus Area")
arrange(pref_resource, pref_gr, pref_metro,
       pref_pov,  pref_sub, pref_sub2, ncol=3)

plot.completion <- function(dim, lim, title) {
y <- tapply(projects$funding_status=="completed",
            list(projects$teacher_prefix, projects[,dim]),
            mean, simplify=T)[c(1,5,6),lim]
y <- y[,sort(y[1,], index.return=T)$ix]
return(plot.percents(y, title, "steelblue"))
}
comp_resources <- plot.completion('resource_type', 1:4, "Resource Type")
comp_gr <- plot.completion('grade_level', 1:4, "Grade Level")
comp_metro <- plot.completion('school_metro', 1:4, "School Metro")
comp_pov <- plot.completion('poverty_level', 1:4, "Poverty Level")
comp_sub <- plot.completion('primary_focus_area', 1:7, "Primary Focus Area")
comp_sub2 <- plot.completion('secondary_focus_area', 2:8, "Secondary Focus Area")
arrange(comp_resources, comp_gr, comp_metro,
        comp_pov, comp_sub, comp_sub2, ncol=3)
        
########## [[LIWC]]
liwc.mean <- mean(projects[,47:110])
liwc.data <- by(projects[,47:110],
                projects$teacher_prefix,
                mean,
                simplify=T)[c(1,5,6)]
liwc.rows <- names(liwc.data$Mr.)
liwc <- data.frame(pref=c(), var=c(), val=c())
liwc <- rbind(liwc,data.frame(pref="Mr", var=liwc.rows, val=liwc.data$Mr./liwc.mean-1))
liwc <- rbind(liwc, data.frame(pref="Mrs", var=liwc.rows, val=liwc.data$Mrs./liwc.mean-1))
liwc <- rbind(liwc, data.frame(pref="Ms", var=liwc.rows, val=liwc.data$Ms./liwc.mean-1))

cats <- read.csv('~/liwc/liwccat2007.csv', header=T, quote="")
cats$var <- as.character(cats$var)
cats$var[cats$var=='you'] = 'you.x'
cats$var[cats$var=='time'] <- 'time.x'
cats$var[cats$var=='i'] <- 'i.x'
liwc <- merge(liwc, cats, by='var')
liwc_plot <- (ggplot(data=liwc, aes(x=pref, y=name)) + theme_bw() +
  opts(plot.margin=unit(c(0.5,1,0,0), "line")) +
  opts(panel.margin=unit(c(0,0,0,0), "line")) +
  geom_tile(aes(fill=val), color="grey") + 
  geom_text(aes(label=paste(round(val*100),"%",sep=""), size=3)) +
  scale_x_discrete(limits=c("Mrs", "Ms", "Mr"),expand=c(0.25,0.25)) +
  scale_y_discrete(expand=c(0,0)) +
  xlab('') + ylab('') + opts(legend.position="none") +
  scale_fill_gradient2(low="red", med="white", high="steelblue"))
  
########## [[LIWC]]
getdict <- function(lims) {
  my.data <- by(projects[,lims],
                projects$teacher_prefix,
                mean,
                simplify=TRUE)[c(1,5,6)]
  my.rows <- names(my.data$Mr.)
  dat <- data.frame(pref=c(), var=c(), val=c())
  dat <- rbind(dat,data.frame(pref="Mr", var=my.rows, val=my.data$Mr.))
  dat <- rbind(dat, data.frame(pref="Mrs", var=my.rows, val=my.data$Mrs.))
  dat <- rbind(dat, data.frame(pref="Ms", var=my.rows, val=my.data$Ms.))
''
  dat.mean <- tapply(dat$val, dat$var, mean)
  dat.mean <- data.frame(mean=dat.mean, var=names(dat.mean))
  dat <- merge(dat, dat.mean, by='var')
  dat$val <- dat$val/dat$mean - 1
  
  return(dat) 
}

liwc <- getdict(47:110)
cats <- read.csv('~/liwc/liwccat2007.csv', header=T, quote="")
cats$var <- as.character(cats$var)
cats$var[cats$var=='you'] = 'you.x'
cats$var[cats$var=='time'] <- 'time.x'
cats$var[cats$var=='i'] <- 'i.x'
liwc <- merge(liwc, cats, by='var')
liwc_plot <- (ggplot(data=liwc, aes(x=pref, y=name)) + theme_bw() +
  opts(plot.margin=unit(c(0.5,1,0,0), "line")) +
  opts(panel.margin=unit(c(0,0,0,0), "line")) +
  geom_tile(aes(fill=val), color="grey") + 
  geom_text(aes(label=paste(round(val*100),"%",sep=""), size=3)) +
  scale_x_discrete(limits=c("Mrs", "Ms", "Mr"),expand=c(0.25,0.25)) +
  scale_y_discrete(expand=c(0,0)) +
  xlab('') + ylab('') + opts(legend.position="none") +
  scale_fill_gradient2(low="red", med="white", high="steelblue"))

###### [[ resources]]
liwc.mean <- mean(projects[,112:311])
liwc.data <- by(projects[,112:311],
                projects$teacher_prefix,
                mean,
                simplify=T)[c(1,5,6)]
liwc.rows <- names(liwc.data$Mr.)
liwc <- data.frame(pref=c(), var=c(), val=c())
liwc <- rbind(liwc,data.frame(pref="Mr", var=liwc.rows, val=liwc.data$Mr./liwc.mean-1))
liwc <- rbind(liwc, data.frame(pref="Mrs", var=liwc.rows, val=liwc.data$Mrs./liwc.mean-1))
liwc <- rbind(liwc, data.frame(pref="Ms", var=liwc.rows, val=liwc.data$Ms./liwc.mean-1))
liwc_plot <- (ggplot(data=liwc, aes(x=pref, y=var)) + theme_bw() +
opts(plot.margin=unit(c(0.5,1,0,0), "line")) +
opts(panel.margin=unit(c(0,0,0,0), "line")) +
geom_tile(aes(fill=val), color="grey") + 
geom_text(aes(label=paste(round(val*100),"%",sep=""), size=3)) +
scale_x_discrete(limits=c("Mrs", "Ms", "Mr"),expand=c(0.25,0.25)) +
scale_y_discrete(expand=c(0,0)) +
xlab('') + ylab('') + opts(legend.position="none") +
scale_fill_gradient2(low="red", med="white", high="steelblue"))