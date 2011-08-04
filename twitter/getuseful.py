#!/usr/bin/env python
# -*- coding: utf-8 -*- 
import codecs
import csv

from sys import argv

outfile = csv.writer(open('data/userdata.csv' if len(argv) == 1 else argv[1],'w'))
infile = open('data/users.csv')

keep = 'profile_use_background_image,id,verified,profile_sidebar_fill_color,is_translator,geo_enabled,profile_text_color,followers_count,protected,default_profile_image,listed_count,utc_offset,statuses_count,description,friends_count,location,profile_link_color,profile_image_url,notifications,show_all_inline_media,profile_background_color,profile_background_image_url,name,lang,profile_background_tile,favourites_count,screen_name,url,created_at,time_zone,profile_sidebar_border_color,default_profile,following,tfavorited,ttruncated,ttext,tcreated_at,tretweeted,tcoordinates,tsource,tin_reply_to_screen_name,tin_reply_to_user_id,tplace,tretweet_count,tgeo'.split(',')
outfile.writerow(keep)
keep = set(keep)

keys = infile.readline().split(',')
keep = [i for i in range(len(keys)) if keys[i] in keep]

for line in csv.reader(infile):
  #line = map(lambda x: x if not isinstance(x,unicode) else x, line)
  outfile.writerow([line[i] for i in keep])
