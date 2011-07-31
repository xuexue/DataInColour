setwd('/Users/xuexue/dataincolour/donorschoose/r/')
source('../../utils/arrange.r')
library('ggplot2')
all <- read.csv("../data/projects.csv")
tampa <- read.csv("../data/projects.tampa.csv")
memphis <- read.csv("../data/projects.memphis.csv")

plot.month <- function(dat, title) {
  dat.melted = melt(table(as.Date(paste(substr(dat$date_posted, 0, 7), '-01', sep='')),
                          dat$funding_status))
  colnames(dat.melted) <- c('month', 'status', 'projects')
  dat.melted$month = as.Date(dat.melted$month)
  return(ggplot(data=dat.melted, aes(x=month, y=projects, group=status, fill=status))
         + theme_bw() + geom_area()
         + scale_x_date(lim = c(as.Date("2008-1-1"), as.Date("2011-4-1")), expand=c(0,0))
         + labs(x="",y="Projects Posted", fill="Funding Status")
         + opts(title=title))
}
all.time <- plot.month(all, "All Donors Choose Projects")
tampa.time <- plot.month(tampa, "Projects in Tampa")
memphis.time <- plot.month(memphis, "Projects in Memphis")
arrange(all.time, tampa.time, memphis.time, ncol=1)

all <- all[substr(as.character(all$date_posted), 1, 4)=='2011', ]
tampa <- tampa[substr(as.character(tampa$date_posted), 1, 4)=='2011', ]
memphis <- memphis[substr(as.character(memphis$date_posted), 1, 4)=='2011', ]

table.percent <- function(dat, var, val, div=TRUE) {
  x <- table(dat[as.character(dat$date_posted)>='2011-01-01',var])[val];
  if(div) {
    return(x/sum(x));
  }
  return (x);
}

test.sig <- function(var, val) {
  t.all <- table.percent(all, var, val)
  print(t.all)
  print(table.percent(tampa, var, val))
  print(chisq.test(table.percent(tampa, var, val, FALSE), p=t.all))
  print(table.percent(memphis, var, val))
  print(chisq.test(table.percent(memphis, var, val, FALSE), p=t.all))
}
test.sig('teacher_prefix',c("Mr.", "Mrs.", "Ms.")) # both sig
test.sig('primary_focus_area',
        c("Applied Learning", "Health & Sports", "History & Civics",
          "Literacy & Language", "Math & Science", "Music & The Arts",
          "Special Needs")) # both sig
test.sig('grade_level',
         c("Grades 3-5", "Grades PreK-2",
          "Grades 6-8", "Grades 9-12")) # both sig
test.sig('poverty_level', c("high", "low"))
test.sig('funding_status', c('completed', 'live', 'reallocated', 'expired'))
test.sig('resource_type',c("Books", "Supplies", "Technology")) # both sig


plot.var <- function(var, val, x) {
  dat <- data.frame()
  t.all <- table.percent(all, var, val)
  dat <- rbind(dat, data.frame(d='All', v=t.all, c=names(t.all)))
  t.tampa <- table.percent(tampa, var, val)
  dat <- rbind(dat, data.frame(d='Tampa', v=t.tampa, c=names(t.tampa)))
  t.memphis <- table.percent(memphis, var, val)
  dat <- rbind(dat, data.frame(d='Memphis', v=t.memphis, c=names(t.memphis)))
  return(ggplot(dat, aes(x=c,weight=v,group=d,fill=d))
         + theme_bw() + geom_bar(position='dodge')
         #+ geom_text(aes(x=c, y=0.5, label=round(v*100)))
         + labs(y="", x="", fill="")
         + scale_y_continuous(formatter="percent")
         + scale_x_discrete(breaks=val, limit=val)
         + opts(title=x, legend.position='none', legend.direction="horizontal"))
}

pref <- plot.var('teacher_prefix',c("Mr.", "Mrs.", "Ms."), "Teacher Prefix")
area <- plot.var('primary_focus_area',
        c("Applied Learning", "Health & Sports", "History & Civics",
         "Literacy & Language", "Math & Science", "Music & The Arts",
          "Special Needs"),
        "Subject Area")
grade <- plot.var('grade_level',
         c("Grades PreK-2", "Grades 3-5", 
           "Grades 6-8", "Grades 9-12"),
         "Grade Level")
pov <- plot.var('poverty_level', c("high", "low"), "Poverty Level")
res <- plot.var('resource_type',c("Books", "Supplies", "Technology"), "Resource Type")
stat <- plot.var('funding_status', c('completed', 'live', 'expired'),
         "Funding Status")
arrange(grade, pref, pov, res)
area + coord_flip() + opts(legend.position='bottom')

plot.var.2 <- function(var, val, x) {
  dat <- data.frame()
  t.all <- table.percent(all, var, val)
  dat <- rbind(dat, data.frame(d='All', v=t.all, c=names(t.all)))
#  t.tampa <- table.percent(tampa, var, val)
#  dat <- rbind(dat, data.frame(d='Tampa', v=t.tampa, c=names(t.tampa)))
  t.memphis <- table.percent(memphis, var, val)
  dat <- rbind(dat, data.frame(d='Memphis', v=t.memphis, c=names(t.memphis)))
  return(ggplot(dat, aes(x=d,weight=v,group=c,fill=c))
         + theme_bw() + geom_bar() 
         + labs(y="", x="", fill=x)
         + scale_y_continuous(formatter="percent")
         + scale_x_discrete(limits=c(), breaks=c(), labels=c())
         + coord_polar(theta="y")
         + opts(legend.position='bottom', legend.direction="horizontal"))
}