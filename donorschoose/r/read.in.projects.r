projects <- read.delim("../data/combined2.csv", fill=F, sep="\t", header=T)
projects$year <- as.integer(substr(as.character(projects$date_posted), 1, 4))
projects <- projects[projects$year <= 2010 & projects$year >= 2004,]
projects <- projects[projects$primary_focus_area != '',]

projects$school_state = as.character(projects$school_state)
projects$school_state[as.character(projects$school_state) == "La"] <- "LA"
projects$school_state = as.factor(projects$school_state)
projects$school_metro = relevel(projects$school_metro, 'urban')
projects$teacher_prefix  = relevel(projects$teacher_prefix, 'Mr.')
projects$primary_focus_area= relevel(factor(projects$primary_focus_area), 'Literacy & Language')
projects$primary_focus_subject= relevel(factor(projects$primary_focus_subject), 'Literacy')
projects$resource_type= relevel(factor(projects$resource_type), 'Books')
projects$grade_level = relevel(factor(projects$grade_level), 'Grades 3-5')
projects$total_donations[is.na(projects$total_donations)] <- 0
projects$num_donors[is.na(projects$num_donors)] <- 0
#projects[,47:110] <- projects[,47:110]*100
projects[,48:111] <- projects[,48:111]*100
