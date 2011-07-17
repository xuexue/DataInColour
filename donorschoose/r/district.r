setwd('/Users/xuexue/dataincolour/donorschoose/r/')
library('ggplot2')
all <- read.csv("../data/projects.csv")
tampa <- read.csv("../data/projects.tampa.csv")
memphis <- read.csv("../data/projects.memphis.csv")

plot.month <- function(dat) {
  dat.melted = melt(table(substr(dat$date_posted, 0, 7)))
  colnames(dat.melted) <- c('month', 'projects')
  return(ggplot(data=dat.melted, aes(x=month, y=projects)) + geom_point())
}
plot.month(all)
plot.month(tampa)
plot.month(memphis)

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
