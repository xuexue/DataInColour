setwd('/Users/xuexue/dataincolour/donorschoose/r/')
library(ggplot2)
library(RColorBrewer)
source('../../utils/arrange.r')
don <- read.delim('../data/first_donation.tsv', quote='',
                  sep='\t', header=T, fill=F, comment.char='')
don$year <- as.integer(substr(as.character(don$donation_timestamp), 1, 4))
don <- don[don$year > 2004,]
don$school_metro = relevel(don$school_metro, 'urban')
don$teacher_prefix  = relevel(don$teacher_prefix, 'Mr.')
don$primary_focus_area= relevel(factor(don$primary_focus_area), 'Literacy & Language')
don$primary_focus_subject= relevel(factor(don$primary_focus_subject), 'Literacy')
don$resource_type= relevel(factor(don$resource_type), 'Books')
don$grade_level = relevel(factor(don$grade_level), 'Grades 3-5')
don$payment_method = relevel(factor(don$payment_method), 'creditcard')
don$resource_usage = relevel(factor(don$resource_usage), 'enrichment')

ret_don = tapply(rep>0, year, mean)
ret_don <- data.frame(year=as.integer(rownames(ret_don)), ret=ret_don)
(ggplot(ret_don, aes(x=year, y=ret)) +geom_line(size=2, color='darkgreen') +
  geom_point(size=3, color='darkgreen')+ theme_bw() + 
  scale_y_continuous(formatter="percent", limits=c(0,.35))+
  labs(x='', y='') + opts(title='Percent New Donors Return within Same Year'))

mod <- glm(I(rep > 0) ~ is_teacher_acct+dollar_amount+
                 donation_included_optional_support+
                 payment_method + payment_included_acct_credit+
                 payment_included_campaign_gift_card+
                 payment_included_web_purchased_gift_card+
                 via_giving_page+for_honoree+thank_you_packet_mailed+
                 school_metro+school_charter+school_year_round+
                 teacher_prefix+teacher_teach_for_america+
                 teacher_ny_teaching_fellow+primary_focus_area+
                 resource_usage+resource_type+poverty_level+
                 grade_level+log(1+total_price_excluding_optional_support)+
                 log(1+students_reached)+
                 eligible_double_your_impact_match+
                 I(as.character(school_state)==as.character(donor_state))+
                 I(funding_status=="completed")+
                 as.factor(year),
    data=don, family=binomial)
glm.out <- data.frame(summary(mod)$coefficients)
glm.out$Estimate = exp(glm.out$Estimate) - 1

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
  proj.weights <- data.frame(val=don[, proj.name])
  proj.weights <- merge(proj.weights, df, by='val')
  m <- mean(proj.weights$est[!is.na(proj.weights$val)])
  df$est <- df$est - m
  # sort it 
  df <- df[sort(df$est, index.return=T)$ix,]
  # plotting time!
  return (
    ggplot(data=df) + theme_bw() +
    opts(plot.margin=unit(c(0,1,0,0), "line")) +
    opts(panel.margin=unit(c(0,0,0,0), "line")) +
    geom_bar(aes(x=val, y=est, fill=est)) + 
    scale_x_discrete(limits=df$val, breaks=c(""), labels=c("")) +
    scale_y_continuous(formatter="percent") + #, limits=c(-.1,.1)) +
    xlab('') + ylab('') + opts(legend.position="none") +
    opts(title=var.name) + coord_flip() + 
    scale_fill_gradient2(low="red", mid="grey", high="steelblue") +
    geom_text(aes(x=val,y=(-est/abs(est))*0.001, label=lab,
              hjust=0.5+0.5*(est/abs(est))), size=4))
}

# binary
glm.binary <- glm.out[c(2,17,15,51,52,53),]
glm.binary$name = c("Donor is Teacher", "Thank You Packet Received",
                    "Donated via Giving Page",
                    "Eligible Double Your Impact Match",
                    "Donor & Project in Same State",
                    "Project Completed")
(ggplot(data=glm.binary)+theme_bw()+
 opts(plot.margin=unit(c(0,1,0,0), "line")) +
 opts(panel.margin=unit(c(0,0,0,0), "line")) +
 geom_bar(aes(x=name, y=Estimate, fill=Estimate)) + 
 scale_y_continuous(formatter="percent",limits=c(-1.5,2.05)) +
 xlab('') + ylab('') + opts(legend.position="none") +
 opts(title='Increase in Odds of Project Completion') + coord_flip() + 
 scale_fill_gradient2(low="red", mid="grey", high="steelblue") +
 scale_x_discrete(limits=rev(glm.binary$name), breaks=c(""), labels=c("")) +
 geom_text(aes(x=name,y=(-Estimate/abs(Estimate))*0.05, label=name,
           hjust=0.5+0.5*(Estimate/abs(Estimate))), size=4))
          
# categorical
dollar <- plot.est(c(3,4), c("100_and_up", "10_to_100", "under_10"),
                   "Donation Dollar Amount",
                   "dollar_amount", c("$100+", "$10-100", "<$10"))
prefix <- plot.est(c(26,27), c("Mr.", "Mrs.", "Ms."),
                   "Teacher Prefix",
                   "teacher_prefix")
metro <- plot.est(19:20, c("urban", "rural", "suburban"),
                  "School Metro","school_metro")
area <- plot.est(30:35, c("Literacy & Language", "Applied Learning", "Health & Sports",
                           "History & Civics", "Math & Science", "Music & The Arts",
                           "Special Needs"),
                  "Subject","primary_focus_area",
                  c("Literacy & Lang",  "Applied Learning", "Health & Sports",
                  "History & Civics", "Math & Science", "Music & The Arts",
                  "Special Needs"))
grade <- plot.est(46:48,
                  c("Grades 3-5", "Grades 6-8", "Grades 9-12", "Grades PreK-2"),
                  "Grade", "grade_level",
                  c("Gr 3-5", "Gr 6-8", "Gr 9-12", "Gr PreK-2"))
pov <- plot.est(43:45, c("high", "low", "minimal", "unknown"), 
               "School Poverty", "poverty_level")
pay <- plot.est(10:11, c("creditcard", "no_cash_received", "paypal"), 
               "Payment Method", "payment_method",
               c("Credit Card", "Previously Paid", "Paypal"))
arrange(dollar, pay, metro, pov, area, grade, ncol=2)