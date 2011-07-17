library(ggplot2)

dd <- read.delim('donation_info', sep='\t', quote="")
dd <- dd[which(dd$dollar_amount != 'WY'), ]
dd$dollar_amount = relevel(factor(dd$dollar_amount), 'under_10')
dd$year <- as.integer(substr(as.character(dd$date_posted), 1, 4))
dd <- dd[which(dd$year <= 2010 & dd$year >= 2004),]

for (a in levels(dd$primary_focus_area)) {
  print(chisq.test(table(dd$dollar_amount[which(dd$primary_focus_area==a)]),
                   p=table(dd$dollar_amount),
                   rescale.p=TRUE))
}

#RESOURCES
table_percent <- function (dim, var) {
  x <- table(dim, var);
  y <- table(dim);
  for (i in 1:ncol(x)) {
    x[,i] <- x[,i]/y
  }
  return(x);
}
rtp <- function(dim,var, n=2) {
  return(round(table_percent(dim, var), n))
}
tp_plot <- function(dim, var, title="", xlab="", ylab="") {
  x = melt(table_percent(dim, var))
  show(qplot(data=x, x=dim, y=value, group=var, 
    color=var, geom="line", main=title, xlab=xlab,
    ylab=ylab, legend.title="Hello"));
}


# DOLLAR AMOUNT BY AREA
rtp(dd$primary_focus_area, dd$dollar_amount)
ggplot(x) + geom_bar(position="dodge", aes(x=dim, fill=relevel(var, 'under_10'), weight=value))
ggplot(x) + geom_bar(position="dodge", aes(fill=dim, x=relevel(var, 'under_10'), weight=value))

ggplot(x) + geom_freqpoly(position="dodge", aes(x=relevel(var, 'under_10'), fill=dim, weight=value))
ggplot(x, aes(x=relevel(var, 'under_10'), color=dim, y=value)) + geom_point() + geom_line()

# STATE &  CITY

dd$same_state = (as.character(dd$donor_state) == as.character(dd$school_state))
dd$same_state[is.na(dd$same_state)] <- FALSE
dd$same_city = (as.character(dd$donor_city) == as.character(dd$school_city) & dd$same_state)
dd$same_city[is.na(dd$same_city)] <- FALSE


city = table_percent(dd$year, dd$same_city)[,2]
state = table_percent(dd$year, dd$same_state)[,2]
z = data.frame(city, state, year=c(2004,2005, 2006, 2007, 2008, 2009, 2010))
z.melt = melt(z)
qplot(data=z.melt, x=year, y=value, group=variable, color=variable, geom="line",
      main="Donations within the same state and city over time")


# STATES
us_state_map = map_data('state');
t(long, lat, data=us_state_map, geom="polygon", group=group, fill=group)
