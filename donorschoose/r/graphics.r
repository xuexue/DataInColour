#setwd('/User/xuexue/dataincolour/donorschoose/r/')
library(ggplot2)
library(RColorBrewer)
source('read.in.projects.r')
source('../../utils/arrange.r')

########## GENERAL FUNCTION FOR TRENDS

table_percent <- function (dim, var) {
  x <- table(dim, var);
  y <- table(dim);
  for (i in 1:ncol(x)) {
    x[,i] <- x[,i]/y
  }
  return(x);
}
tp_plot <- function(dim, var, keep=c(), title="", labs=c()) {
  x = melt(table_percent(dim, var))
  x$col <- "Others"
  for (i in keep) {
    x$col[x$var == i] <- i
  }
  colors = c(brewer.pal(length(keep)+1, "Dark2")[1:length(keep)],"grey")
  limits_ordered = keep
  if (length(labs) == 0) {
    labs=keep
  }
  if (any(x$col == "Others")) {
    limits_ordered = c(keep, "Others");
    labs = c(labs, "Others");
  }
  return(ggplot(data=x ,#[x$col!="Others",],
                aes(x=dim, y=value, group=var, color=col)) +
    geom_line(size=1) + geom_point(size=2) +
    opts(title="") +
    labs(x=title, y="", colour="") + 
    scale_y_continuous(formatter="percent")+
    scale_color_manual(values=colors, limits=limits_ordered,
                      breaks=limits_ordered, labels=labs)+ 
    opts(plot.margin=unit(c(0,1,0,0), "lines")) + 
    opts(legend.direction="horizontal", legend.position="bottom",
         legend.key.size=unit(c(1,1),"lines")))
}


########## [[ PROJECTS ]]
#latlong <- read.delim('school_latlong', sep='\t', quote="", header=T)
base <- (ggplot(data=projects, aes(x=school_longitude, 
  y=school_latitude)) + 
  coord_cartesian(xlim=c(-125, -65), ylim=c(24,50)) +
  opts(title = "Donors Choose Projects in the Continential USA") +
  xlab("") + ylab(""));
school_plot <- (base + geom_point(alpha=0.7, size=1, color="steelblue") +
  scale_x_continuous(breaks = NA) + scale_y_continuous(breaks = NA))
school_plot

########## [[ GROWTH ]]
donations <- data.frame(donation=tapply(projects$total_donations,
                                        projects$year, sum)/1000000)
donations$year <- as.numeric(rownames(donations))
donations_plot <- (ggplot(data=donations) +
  geom_line(aes(x=year, y=donation), size=1.5, color='steelblue') + 
  geom_point(aes(x=year, y=donation), size=3, color='steelblue') + 
  opts(title = "Donation Amount ($million)") + xlab("") +
  scale_y_continuous(limit=c(0,34),  expand=c(0,0)) +
  ylab("") + opts(plot.margin=unit(rep(0.2, 4), "lines")) + 
  opts(axis.title.x = theme_blank(), axis.title.y = theme_blank()))
  
donors <- data.frame(donors=tapply(projects$num_donors,
                                   projects$year, sum)/1000)
donors$year <- as.numeric(rownames(donors))
donors_plot <- (ggplot(data=donors) +
  geom_line(aes(x=year, y=donors), size=1.5, color='purple') + 
  geom_point(aes(x=year, y=donors), size=3, color='purple') + 
  opts(title = "Donations (thousand)") + xlab("") +
  scale_y_continuous(limit=c(0,430),  expand=c(0,0)) +
  ylab("") + opts(plot.margin=unit(rep(0.2, 4), "lines")) + 
  opts(axis.title.x = theme_blank(), axis.title.y = theme_blank()))

nproj <- data.frame(project = table(projects$year)/1000)
colnames(nproj) <- c("year", "project")
nproj$year <- as.numeric(as.character(nproj$year))
nproj_plot <- (ggplot(data=nproj) +
  geom_line(aes(x=year, y=project), size=1.5, color='darkgreen') + 
  geom_point(aes(x=year, y=project), size=3, color='darkgreen') + 
  scale_y_continuous(limit=c(0,90), expand=c(0,0)) +
  opts(title = "Projects (thousand)") + xlab("") +
  ylab("") + opts(plot.margin=unit(rep(0.2, 4), "lines")) + 
  opts(axis.title.x = theme_blank(), axis.title.y = theme_blank()))
  
arrange(nproj_plot, donors_plot, donations_plot, ncol=3)

########## [[DONATION PER PROJECT]]
ndon <- data.frame(don=tapply(projects$num_donors, projects$year, mean), year=2004:2010)
ndon_plot <- (ggplot(data=ndon) +
  geom_line(aes(x=year, y=don), size=1.5, color='red')+
  geom_point(aes(x=year, y=don), size=3, color='red')+
  opts(title="Donors per project") + xlab("") + 
  scale_y_continuous(limit=c(0,4.9),  expand=c(0,0)) +
  ylab("") + opts(plot.margin=unit(rep(0, 4), "lines")) + 
  opts(axis.title.x = theme_blank(), axis.title.y = theme_blank()))

don_proj = data.frame(
  year=2004:2010,
  requested=tapply(projects$total_price_including_optional_support, projects$year, mean),
  donated=tapply(projects$total_donations, projects$year, mean));
don_proj = melt(don_proj, id='year');
don_proj$variable <- as.character(don_proj$variable)
don_proj$variable[don_proj$variable == 'requested'] <- 'Average Amount ($) Requested'
don_proj$variable[don_proj$variable == 'donated'] <- 'Average Amount ($) Donated'
don_proj$variable <- as.factor(don_proj$variable)

don_proj_plot <- (
ggplot(data=don_proj, aes(x=year, y=value, group=variable, colour=variable)) +
geom_line(size=1.5) + 
geom_point(size=3) + 
opts(title = "Donations Per Project By Year") + xlab("") +
ylab("") +
scale_y_continuous(formatter="dollar", limit=c(0,900), expand=c(0,0)) + 
labs(colour = "") + 
opts(legend.position="bottom", legend.direction="horizontal"))

########## [[FUNDING STATUS]]
tp_plot(projects$year, projects$funding_status, "Funding Status Breakdown by Year", "", "")

########## [[GRADE LEVEL]]
#grades <- tp_plot(projects$year, projects$grade_level, 
#                  c("Grades PreK-2", ),
#                  "Grade Level Breakdown by Year")

########## [[METRO]]
metro_subset = (projects$school_metro != "")
metro <- tp_plot(projects$year[metro_subset],
                 factor(projects$school_metro[metro_subset]),
                 c("urban", "rural", "suburban"), 
                 "School Metro by Year",
                 c("Urban", "Rural", "Suburban"))

########## [[RESOURCE TYPE]]
resources <- tp_plot(projects$year, projects$resource_type, 
                    c("Supplies","Technology"),
                    "Resource Type by Year")
                    
########## [[POVERTY]]
poverty <- tp_plot(projects$year, projects$poverty_level,
                    c("high", "low","minimal"),
                    "School Poverty Level by Year",
                    c("High", "Low", "Minimal"))

########## [[PREFIX ]]
teacher_subset = (projects$teacher_prefix != '' & 
                  projects$teacher_prefix != "Mr. & Mrs.")
teacher <- (tp_plot(projects$year,
                    factor(projects$teacher_prefix),
                    c("Mr.","Mrs.", "Ms."),
                    "Teacher Prefix by Year"))

########## [[SUBJECT]]
subject <- (tp_plot(projects$year, projects$primary_focus_area, 
        c("Applied Learning", "Math & Science", "Literacy & Language",
          "Special Needs"),
        "Subject Area by Year",
        c("Applied\nLearning", "Math\nSci", "Literacy\nLang", "Special\nNeeds")))
arrange(poverty, metro, subject, resources, ncol=2)

########## STUDENTS REACHED
projects$students_reached[ is.na(projects$students_reached)] <- 0
m = tapply(projects$students_reached, projects$year, mean)
m.sd = tapply(projects$students_reached, projects$year, sd)
reach = data.frame(year=row.names(m), n=m, low=(m-m.sd), high=(m+m.sd))
(qplot(year, n, data=reach) + 
 geom_smooth(aes(ymin=low, ymax=high)))
 
 
######### EXPERIMENTAL

y <- tapply(projects$funding_status=="completed",
            list(projects$primary_focus_area, projects$resource_type),
            mean, simplify=T)
y.m <- melt(y)
(ggplot(data=y.m) + geom_tile(aes(x=X2, y=X1, fill=value)) +
  geom_text(aes(x=X2, y=X1, label=paste(round(100*value),"%", sep=""))) + 
  scale_fill_gradient(low="white", high="steelblue", limits=c(.3,.85)) +
  scale_x_discrete(name="", expand = c(0,0)) +
  scale_y_discrete(name="", expand = c(0,0)) +
  opts(legend.position="none"))

y <- tapply(projects$year<"2011",
            list(projects$teacher_prefix projects$resource_type),
            sum, simplify=T)[,1:4]
y.m <- melt(y)
(ggplot(data=y.m) + geom_tile(aes(x=X2, y=X1, fill=value)) +
  scale_fill_gradient(low="white", high="steelblue") +
  scale_x_discrete(expand = c(0,0)) + scale_y_discrete(expand = c(0,0)))

y <- tapply(projects$funding_status=="completed",
            list(projects$teacher_prefix, projects$resource_type),
            mean, simplify=T)[c(1,5,6),1:4]
y.m <- melt(y)
(ggplot(data=y.m) + geom_tile(aes(x=X2, y=X1, fill=value)) +
  scale_fill_gradient(low="white", high="steelblue") +
  scale_x_discrete(expand = c(0,0)) + scale_y_discrete(expand = c(0,0)))

  
y_before <- tapply(projects$year=="2005",
    list(projects$primary_focus_area, projects$resource_type),
    sum, simplify=T)[,1:4] / sum(projects$year == "2005")
y_after <- tapply(projects$year=="2010",
    list(projects$primary_focus_area, projects$resource_type),
    sum, simplify=T)[,1:4] / sum(projects$year == "2010")
y.m <- melt(y_after/y_before - 1)
(ggplot(data=y.m) + geom_tile(aes(x=X2, y=X1, fill=value)) +
  geom_text(aes(x=X2, y=X1, label=paste(round(value*100),"%", sep="")), size=4)+
  scale_fill_gradient2(low="red", med="white", high="steelblue")+
  scale_x_discrete(name="", expand = c(0,0)) +
  scale_y_discrete(name="", expand = c(0,0)) +
  opts(plot.margin=unit(c(0.5, 1, 0, 0), "lines")) +
  opts(legend.position="none") +
  opts(title="Growth in Number of Projects: 2005 to 2010")
  )