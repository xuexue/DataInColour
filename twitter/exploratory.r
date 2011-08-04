setwd('/Users/xuexue/dataincolour/twitter')
library(ggplot2)
useful <- read.csv('data/userdata.csv', header=T)
summary(useful)

attach(useful)

hist(id, breaks=200) # disproportionally few around 0 and 200000000
#table(verified) # only two...
plot(profile_sidebar_fill_color) # the default one really shows up
#table(is_translator) # one...
table(geo_enabled) # about 7.5 % true
plot(profile_text_color) # mostly default one, again...
hist(log(1+followers_count), breaks=200) # still log decline
table(protected) # about 7.8 % true
table(default_profile_image) # 58% true
hist(log(1+listed_count), breaks=80) # yeah... worse than log decline
hist(log(1+statuses_count), breaks=80) # log decline
table(description == '') # 80 % true
hist(log(1+friends_count)) # not log decline
table(location == '') # 73 % true
plot(profile_link_color) # as expected..
length(grep('default_profile', profile_image_url))/nrow(useful) # 58%
table(notifications) # either False or blank (1.1% blank)
table(show_all_inline_media) # 4% true
plot(profile_background_color)
length(grep('images/themes/theme', profile_background_image_url))/nrow(useful) # 87%
table(name == '') # 1 / 86k true
table(lang)/nrow(useful)*100 # 78% en, 12% es, 5% ja
table(profile_background_tile)/nrow(useful) # 14 % true
hist(log(1+favourites_count)) # bigger than log decrease
table(screen_name == '') # .4% true
table(url == '')/nrow(useful) # 9% false
head(table(url)[rev(order(table(url)))] # <-------
plot(profile_sidebar_border_color)
table(default_profile)
table(following)

todate <- function(x) {
  return(as.Date(paste(substr(x, 27, 32), substr(x,5,15)), '%Y %b %d'))
}
created_dt <- todate(created_at)
plot(created_dt, useful$id)
ggplot(useful) + geom_line(aes(x=created_dt, y=id))