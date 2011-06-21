library(ggplot2)
library(lasso2)
library(RColorBrewer)
source('read.in.projects.r')
source('../../utils/arrange.r')

####### MAKE GLM MODEL!

# use l1 regularization to do feature selection
#glm.model.l1 =  gl1ce(I(funding_status=="completed") ~ 
#  school_latitude + school_longitude + school_latitude:school_longitude +
#  school_metro + school_charter + school_magnet + school_year_round + 
#  school_nlns +
#  school_kipp + teacher_prefix + teacher_teach_for_america +
#  teacher_ny_teaching_fellow + primary_focus_subject +
#  resource_usage + resource_type +
#  poverty_level + grade_level + log(students_reached+1) +
#  log(total_price_excluding_optional_support+1) +
#  eligible_double_your_impact_match + eligible_almost_home_match +
#  as.factor(year) + ingest + cause + insight + cogmech + sad  + certain +
#  tentat + discrep + space + time + excl + incl + relativ + motion + quant +
#  number +  funct + + shehe + you + ipron + they + death + bio + body + hear +
#  feel + percept + see + filler + health + sexual + social + family + friend +
#  humans + posemo + negemo + assent + nonfl + verb + article + past + auxverb +
#  future + present + preps + adverb + negate + conj + home + leisure +
#  achieve + work + relig + money + n,
#  data=projects, family=binomial(link=logit), subset=(as.character(date_posted) < '2010-09-30'),
#  bound=5) # play around with te bounds to remove some liwc word categories

# final model
glm.model.final =  glm(I(funding_status=="completed") ~ 
  school_latitude + school_longitude + school_latitude:school_longitude +
  school_metro + school_charter + school_magnet + school_year_round + 
  school_nlns + school_kipp + teacher_prefix + teacher_teach_for_america +
  teacher_ny_teaching_fellow + resource_usage +
  primary_focus_area:resource_type + 
  poverty_level + grade_level + log(students_reached+1) + 
  log(total_price_excluding_optional_support+1) + 
  eligible_double_your_impact_match + eligible_almost_home_match +
  as.factor(year) +
  ingest + cause + insight + cogmech + sad  + certain + tentat + discrep +
  space + time + excl + incl + relativ + motion + quant + number +  funct + 
  shehe + you + ipron + they + death + bio + body + hear + feel +
  percept + see + filler + health + sexual + social + family + friend + humans +
  posemo + negemo + assent + nonfl + verb + article + past + auxverb +
  future + present + preps + adverb + negate + conj + home + leisure + achieve +
  work + relig + money + n,
  data=projects, family=binomial(link=logit),
  subset=(as.character(date_posted) < '2010-09-30')) #253569

sum.glm.model.final <- summary(glm.model.final)
glm.out <- data.frame(sum.glm.model.final$coefficients)

####### PLOT THE GLM MODEL!

#glm.out <- read.csv('glm.out', header=TRUE)
glm.out$Estimate = exp(glm.out$Estimate) - 1 # calculate delta odds ratio
colnames(glm.out) <- c("Estimate", "stderr", "z", "p")
glm.out$name <- rownames(glm.out)
write.csv(glm.out, '../data/glm.out')

#### generic plotting function for plotting the estimates of the odds ratio
plot.est <- function(ns, names, var.name, proj.name) {
  df <- data.frame(est=c(0, glm.out[ns, "Estimate"]),
                    val=names)
  # right now all odds ratio differences are w.r.t. the first category
  # which is arbitrary and isn't very interpretable. the solution is 
  # calculate the weighted average of the odds ratio, depending on
  # the number of projects exist with that category.
  proj.weights <- data.frame(
      val=projects[as.character(projects$date_posted) < '2010-09-30',
                   proj.name])
  proj.weights <- merge(proj.weights, df, by='val')
  m <- mean(proj.weights$est[!is.na(proj.weights$val)])
  df$est <- df$est - m
  # sort it 
  df <- df[sort(df$est, index.return=T)$ix,]
  # plotting time!
  return (
    ggplot(data=df) + 
    geom_bar(aes(x=val, y=est, fill=est)) + 
    scale_x_discrete(limits=df$val,) +
    scale_y_continuous(formatter="percent", limits=c(-.35,.3)) +
    xlab(var.name) + ylab('') + opts(legend.position="none") +
    opts(title="") + coord_flip() + 
    scale_fill_gradient2(low="red", mid="grey", high="steelblue") +
    opts(plot.margin=unit(c(0,1,0,0), "lines"))
  )
}

#### school_metro
metro <- plot.est(4:6, c("urban", "blank", "rural", "suburban"), "School Metro",
                  "school_metro")
#### resource type
resource <- plot.est(c(47:51), 
                     c("Books", "Other", "Supplies", "Technology", "Trips",
                      "Visitors"),
                     "Resource Type", "resource_type")
#### grade
grade <- plot.est(c(55:57),
                  c("Grades 3-5", "Grades 6-8", "Grades 9-12", "Grades PreK-2"),
                  "Grade", "grade_level")
#### teacher prefix
prefix <- plot.est(c(15,16), c("Mr.", "Mrs.", "Ms."), "Teacher Prefix",
                   "teacher_prefix")

#### poverty level
pov <- plot.est(c(52:54), c("high", "low", "minimal", "unknown"), 
               "School Poverty", "poverty_level")
#### plot the four together
arrange(resource, prefix, metro, pov, ncol=2)

year <- plot.est(62:67, 2004:2010, "Year", "year")

#### subjects
subject.levels <- c("Literacy", "Applied Sciences", "Character Education" , 
  "Civics & Government", "College & Career Prep", "Community Service" ,
  "Early Development", "Economics", "Environmental Science",
  "ESL", "Extracurricular", "Foreign Languages",
  "Gym & Fitness", "Health & Life Science", "Health & Wellness",
  "History & Geography", "Literature & Writing", "Mathematics",
  "Music", "Nutrition", "Other",
  "Parent Involvement", "Performing Arts", "Social Sciences",
  "Special Needs", "Sports", "Visual Arts")   
subjects <- plot.est(19:44, subject.levels, "Subject", "primary_focus_subject")
subjects <- (subjects + opts(title="Change in Odds of Project Completion")  
             +scale_y_continuous(formatter="percent", limits=c(-.5,.7)))
#### word categories
words.dat=data.frame(var=as.character(glm.out[68:122,"name"]),
                      est=glm.out[68:122,"Estimate"],
                      p=glm.out[68:122,"p"])
words.dat <- words.dat[words.dat$p < 0.05,] # only take significant ones
# merge it with liwc category names
liwc <- read.csv('~/liwc/liwccat2007.csv', header=T, quote="")
words.dat <- merge(words.dat, liwc, by='var')
words.dat <- words.dat[sort(words.dat$est, index.return=T)$ix,]
# plot
words <- (
  ggplot(data=words.dat) +
  geom_bar(aes(x=name, y=est, fill=est)) +
  coord_flip() + xlab("") + ylab("") +
  opts(title="Change in Odds of Project Completion per 1% Increase use of Words in Category") +
  scale_y_continuous(formatter="percent") +
  scale_fill_gradient2(low="red", mid="grey", high="steelblue") +
  scale_x_discrete(limits=words.dat$name, expand=c(0.02,0.02)) +
  opts(legend.position="none"))
  
words <- data.frame(name=names(glm.model.l1$coefficients[68:122]), 
                    var=glm.model.l1$coefficients[68:122])
words <- words[sort(words$var, index.return=T)$ix,]
(ggplot(data=words) + geom_bar(aes(x=name, y=var)) + coord_flip() 
  +  scale_y_continuous(formatter="percent") +
  scale_x_discrete(limits=words$name) +
  opts(legend.position="none"))

