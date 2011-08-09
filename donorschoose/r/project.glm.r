setwd('/Users/xuexue/dataincolour/donorschoose/r/')
library(ggplot2)
library(lasso2)
library(RColorBrewer)
#source('read.in.projects.r')
#source('../../utils/arrange.r')

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
  poverty_level + grade_level + log(students_reached+1) + 
  log(total_price_excluding_optional_support+1) + 
  eligible_double_your_impact_match + eligible_almost_home_match +
  as.factor(year) +
  ingest + cause + insight + cogmech + sad  + certain + tentat + discrep +
  space + time.x + excl + incl + relativ + motion + quant + number +  funct + 
  shehe + you.x + ipron + they + death + bio + body + hear + feel +
  percept + see + filler + health + sexual + social + family + friend + humans +
  posemo + negemo + assent + nonfl + verb + article + past + auxverb +
  future + present + preps + adverb + negate + conj + home + leisure + achieve +
  work + relig + money + n +
  essay_books + essay_reading + essay_math + essay_read + essay_science + 
  essay_children + essay_would + essay_our + essay_we + essay_learning + 
  essay_book + essay_skills + essay_writing + essay_classroom + 
  essay_technology + essay_materials + essay_music + essay_as + 
  essay_these + essay_art + essay_work + essay_use + essay_class +
  essay_about + essay_learn + essay_able + essay_more + essay_year + 
  essay_time + essay_love + essay_you + essay_s + essay_or + essay_world +
  essay_them + essay_can + essay_many + essay_language + essay_do + 
  essay_so + essay_all + essay_am + essay_want + essay_not + essay_how + 
  essay_each + essay_it + essay_by + essay_student + essay_an + essay_kids+ 
  essay_at + essay_library + essay_grade + essay_but + essay_new + 
  essay_one + essay_what + essay_make + essay_t + essay_center + 
  essay_like + essay_high + essay_they + essay_who + essay_me + 
  essay_also + essay_allow + essay_computer + essay_when + essay_get + 
  essay_activities + essay_help + essay_very + essay_first + 
  essay_readers + essay_see + essay_provide + essay_level + 
  essay_on + essay_english + essay_from + essay_through +
  essay_supplies + essay_camera + essay_their + essay_games +
  essay_home + essay_resources + essay_own + essay_hands + essay_which +
  essay_life + essay_day + essay_education + essay_project + essay_this + 
  essay_has + essay_up + essay_some + essay_other + essay_create + 
  essay_program + essay_because + essay_teach + essay_only + essay_way + 
  essay_teacher + essay_fun + essay_us + essay_experience + 
  essay_listening + essay_come + essay_opportunity + essay_out +
  essay_most + essay_projector + essay_into + essay_give + essay_well + 
  essay_take + essay_could + essay_college + essay_be + essay_using + 
  essay_will + essay_great + essay_community + essay_become + essay_i + 
  essay_practice + essay_just + essay_every + essay_paper + 
  essay_different + essay_words + essay_having + essay_kindergarten + 
  essay_if + essay_where + essay_play + essay_special + essay_small + 
  essay_been + essay_your + essay_there + essay_much + essay_while + 
  essay_group + essay_know + essay_literacy + essay_important + 
  essay_needs + essay_better + essay_teaching + essay_used + essay_set + 
  essay_access + essay_projects + essay_years + essay_was + essay_during +
  essay_no + essay_stories + essay_being + essay_such + essay_learners + 
  essay_that + essay_graders + essay_school + essay_digital + 
  essay_parents + essay_literature + essay_over + essay_support + 
  essay_write + essay_hard + essay_feel + essay_even + essay_child + 
  essay_concepts + essay_area + essay_low + essay_order + essay_than + 
  essay_second + essay_place + essay_had + essay_working + essay_keep + 
  essay_with + essay_social + essay_two + essay_share + essay_possible + 
  essay_lessons + essay_centers + essay_lives + essay_classes + 
  essay_often +
  illustrator+ book +                                                                                                                            
  set + level + read+ paper + gr + pack + i.x + comments + library + cd +
  kit + math + with + school + books + seuss + complete +
  center + dr + black + game + kids + david + reading +
  you.y + digital + amp + hp + my + can + editor + color +
  time.y + on + magic + john + w + box + world + blue +
  activity + b + l + big + classroom + red +
  construction + science + grade + is + markers + j + 
  white + word + mary + learning + brown + cards +
  crayola + m + story + board + house + bin + camera +
  d + k + it + extra + games + translator + magnetic +
  little + readers + edition + orders + lakeshore +
  projector + eric + colors + erase + write + o + 
  washable + all + from + green + chart + dry + grades +
  nancy + pocket + nonfiction + tree + de + paul +
  student + smart + james + about + e + art + life +
  assorted + how + paint + carle + t + your + high +
  pope + along + cartridge + pk + day + first + quill +
  size + volume + guide + card + who + osborne + alphabet +
  robert + one + dk + american + c + brand + smith +
  tempera + jones + patricia + michael + h + pencil +
  pencils + murdocca + what + berenstain + photo + wipe +
  flash + sheets + arthur + best + up + kid +
  comprehension + at + collection + interact
  ,
  data=projects, family=binomial(link=logit),
  subset=(as.character(date_posted) < '2010-09-30')) #253569

sum.glm.model.final <- summary(glm.model.final)
glm.out <- data.frame(sum.glm.model.final$coefficients)

####### PLOT THE GLM MODEL!

glm.out$Estimate = exp(glm.out$Estimate) - 1 # calculate delta odds ratio
colnames(glm.out) <- c("Estimate", "stderr", "z", "p")
glm.out$name <- rownames(glm.out)
write.csv(glm.out, '../data/glm.out.big')
#glm.out <- read.csv('../data/glm.out', header=TRUE)

#### generic plotting function for plotting the estimates of the odds ratio
plot.est <- function(ns, names, var.name, proj.name, labels=c()) {
  if (length(labels) == 0) {
    labels=names
  }
  df <- data.frame(est=c(0, glm.out[ns, "Estimate"]),
                    val=names,
                    lab=labels)
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
  print(df)
  return (
    ggplot(data=df) + theme_bw() +
    opts(plot.margin=unit(c(0,1,0,0), "line")) +
    opts(panel.margin=unit(c(0,0,0,0), "line")) +
    geom_bar(aes(x=val, y=est, fill=est)) + 
    scale_x_discrete(limits=df$val, breaks=c(""), labels=c("")) +
    scale_y_continuous(formatter="percent", limits=c(-.3,.3)) +
    xlab('') + ylab('') + opts(legend.position="none") +
    opts(title=var.name) + coord_flip() + 
    scale_fill_gradient2(low="red", mid="grey", high="steelblue") +
    geom_text(aes(x=val,y=(-est/abs(est))*0.005, label=lab,
              hjust=0.5+0.5*(est/abs(est))), size=4))
}

#### resource type
resource <- plot.est(c(47:51), 
                     c("Books", "Other", "Supplies", "Technology", "Trips",
                      "Visitors"),
                     "Resource Type", "resource_type")

#### teacher prefix
prefix <- plot.est(c(15,16), c("Mr.", "Mrs.", "Ms."),
                   "Effect of Teacher Prefix on Odds of Project Completion",
                   "teacher_prefix")

#### school_metro
metro <- plot.est(4:6, c("urban", "blank", "rural", "suburban"), "School Metro",
                  "school_metro")

#### grade
grade <- plot.est(c(24:26),
                  c("Grades 3-5", "Grades 6-8", "Grades 9-12", "Grades PreK-2"),
                  "Grade", "grade_level",
                  c("Gr 3-5", "Gr 6-8", "Gr 9-12", "Gr PreK-2"))

#### poverty level
pov <- plot.est(c(21:23), c("high", "low", "minimal", "unknown"), 
               "School Poverty", "poverty_level")
#### plot the four together
arrange(metro, pov, grade, ncol=3)

#### primary focus area & resource type
interaction <- function() {
areas = levels(projects$primary_focus_area)
types = levels(projects$resource_type)
df = data.frame(est=c(0, glm.out$Estimate[447:487]),
                old=glm.out$name[446:487],
                val=levels(projects$interact))
df$area <- rep(areas, length(types))
df$type <- rep(types, each=length(areas))

proj.weights <- data.frame(
    val=projects$interact[as.character(projects$date_posted) < '2010-09-30'])
proj.weights <- merge(proj.weights, df, by='val')
m <- mean(proj.weights$est[!is.na(proj.weights$val)])
df$est <- df$est - m

/*
overall_type <- c()
for (type in types) {
  x = (sum(df$est[df$type==type] *
       table(projects$primary_focus_area[projects$resource_type == type])
      )
  )/nrow(projects)
  overall_type=c(overall_type,x)
}
overall_area <- c()
for (area in areas) {
  x = (sum(df$est[df$area==area] *
       table(projects$resource_type[projects$primary_focus_area == area])
      )
  )/nrow(projects)
  overall_area=c(overall_area,x)
}

df_overall <- data.frame(
  est = c(overall_type, overall_area),
  old = rep('', 13),
  val = rep('', 13),
  area = c(rep('Total', length(types)), areas),
  type = c(types, rep('Total', length(areas))))
#df <- rbind(df, df_overall)

df <- df[df$type !='Trips' & df$type != 'Visitors',]

return (ggplot(data=df,aes(x=type, y=area))
        + geom_tile(aes(fill=est))
        + geom_text(aes(label=paste(round(est*100),"%")))
        + scale_fill_gradient2(low="red", mid="white", high="steelblue",
                                limits=c(-0.5,0.5))
        + opts(legend.position="none")
        + scale_x_discrete(expand=c(0,0), name="", breaks=c('Total', types))
        + scale_y_discrete(expand=c(0,0), name="", breaks=c('Total', areas))
        + geom_hline(yintercept=7.5, color="grey")
        + geom_vline(xintercept=4.5, color="grey")
        + opts(title="Difference in Odds of Project Completion (Compared to Avg)")
        )
}


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
words.dat=data.frame(var=as.character(glm.out[37:91,"name"]),
                      est=glm.out[37:91,"Estimate"],
                      p=glm.out[37:91,"p"])
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
  geom_text(aes(x=name,y=(-est/abs(est))*0.000002, label=name,
            hjust=0.5+0.5*(est/abs(est)))) +
  scale_x_discrete(limits=words.dat$name, expand=c(0.02,0.02),
                   breaks=c(""), labels=c(""))+ theme_bw() +
  opts(legend.position="none") )

essay <- glm.out[93:292,]
essay <- essay[essay$p < 0.001,]
essay$name <- factor(substr(essay$name, 7, 1000000L))
essay <- essay[sort(essay$Estimate, index.return=T)$ix,]
essay_words_plot <- (
 ggplot(data=essay)+geom_bar(aes(x=name, y=Estimate, fill=Estimate)) +
 scale_fill_gradient2(low="red", mid="grey", high="steelblue")+
 scale_x_discrete(limits=essay$name, expand=c(0.02,0.02), name="",
                  breaks=c(""), labels=c("")) +
 scale_y_continuous(name="", formatter="percent") + coord_flip() + theme_bw() +
 opts(legend.position="none") + 
 geom_text(aes(x=name,y=(-Estimate/abs(Estimate))*0.01, label=name,
           hjust=0.5+0.5*(Estimate/abs(Estimate)))) + 
 opts(title="Word in Essay on Odds of Project Completion"))

resource <- glm.out[c(293:300,302:446),]
resource <- resource[resource$p < 0.05,]
resource$name <- factor(resource$name)
resource <- resource[sort(resource$Estimate, index.return=T)$ix,]
resource_words_plot <- (
 ggplot(data=resource)+geom_bar(aes(x=name, y=Estimate, fill=Estimate)) +
 scale_fill_gradient2(low="red", mid="grey", high="steelblue")+
 scale_x_discrete(limits=resource$name, expand=c(0.02,0.02), name="",
                  breaks=c(""), labels=c("")) +
 scale_y_continuous(name="", formatter="percent") +
 geom_text(aes(x=name,y=(-Estimate/abs(Estimate))*0.01, label=name,
           hjust=0.5+0.5*(Estimate/abs(Estimate)))) +
 coord_flip() + theme_bw() +
 opts(legend.position="none") + 
 opts(title="Word in Resource Name on Odds of Project Completion"))

