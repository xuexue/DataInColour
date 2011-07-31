require(maps)
require(ggplot2)

states = c("alabama","arizona","arkansas","california",
  "colorado","connecticut","delaware","district of columbia",
  "florida","georgia","idaho","illinois",
  "indiana","iowa","kansas","kentucky",
  "louisiana","maine","maryland","massachusetts",
  "michigan","minnesota","mississippi","missouri",
  "montana","nebraska","nevada","new hampshire",
  "new jersey","new mexico","new york","north carolina",
  "north dakota","ohio","oklahoma","oregon",
  "pennsylvania","rhode island","south carolina","south dakota",
  "tennessee","texas","utah","vermont",
  "virginia","washington","west virginia","wisconsin",
  "wyoming")
dataset <- data.frame(region=states,val=runif(49, 0,1))

us_state_map <- map_data('state');
map_data <- merge(us_state_map, dataset, by = 'region', all=T);
map_data <- map_data[order(map_data$order), ];

(qplot(long, lat, data=map_data, geom="polygon", group=group, fill=val) 
 + theme_bw() + labs(x="", y="", fill="")
 + scale_fill_gradient(low='#EEEEEE', high='darkgreen')
 + opts(title="I was created using gplot2!",
        legend.position="bottom", legend.direction="horizontal"))