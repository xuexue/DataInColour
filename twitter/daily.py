#!/usr/bin/env python
# -*- coding: utf-8 -*- 
'''Generate daily metrics including
(1) number of new users per day,
(2) percentage of total user accounts not deleted as of each day,
      = total deleted users scraped / total all users scraped
(3) number of active users per day

This script assumes that we have run:
grep 'not found' usrs | sort -t$'\t' -k1,1 -n > notfound.usrs
'''
import codecs
import time
import csv
from collections import defaultdict

##### make estimations based on still exsisting users
sorted_dt = []
dt_min_uid = {}
dt_max_uid = {}
dt_num_yes = defaultdict(lambda: 0) # new accnt registered that still exists
dt_inactivation = defaultdict(lambda: 0) # inactivation resulted on a date
dt_nonactive = defaultdict(lambda: 0) # new accnt registered but no tweet ever

sorted = open('data/sorted.csv')
header = sorted.readline().split(',')
id = header.index('id')
created_at = header.index('created_at')   # creation date
tcreated_at = header.index('tcreated_at') # last tweet
for line in csv.reader(sorted):
  dt = time.strptime(line[created_at].replace('+0000 ', ''))
  dtstr = '%04.d%02.d%02.d' % (dt.tm_year, dt.tm_mon, dt.tm_mday)
  # update min & max uid
  if not dt_min_uid.get(dtstr):
    dt_min_uid[dtstr] = line[id]
  dt_max_uid[dtstr] = line[id]
  # update num yes
  dt_num_yes[dtstr] += 1
  # inactive date
  if len(line) <= tcreated_at or line[tcreated_at] == 'null' or not line[tcreated_at]:
    dt_inactivation[dtstr] += 1
    dt_nonactive[dtstr] += 1
  else:
    idt = time.strptime(line[tcreated_at].replace('+0000 ', ''))
    idtstr = '%04.d%02.d%02.d' % (idt.tm_year, idt.tm_mon, idt.tm_mday)
    dt_inactivation[idtstr] += 1
  # too lazy to sort stuff so keep a list of sorted str
  if not sorted_dt or sorted_dt[-1] != dtstr:
    sorted_dt.append(dtstr)

##### naively estimate the LAST uid registered on a given date
dt_uid_cutoff = {}
last_min = 0
for dt in sorted_dt:
  dt_uid_cutoff[dt] = (int(dt_max_uid[dt]) + last_min)/2
  last_min = int(dt_min_uid[dt])

##### make estimations based on no longer exsisting users
dt_num_no = defaultdict(lambda: 0) # new accnt registered that does not exist
idx = 0
dt = sorted_dt[idx]
for line in codecs.open('data/notfound.usrs', 'r', 'utf-8'):
  id = int(line.split('\t')[0])
  while id > dt_uid_cutoff[dt] and idx < len(sorted_dt)-1:
    idx += 1
    dt = sorted_dt[idx]
  dt_num_no[dt] += 1

##### now make REAL daily estimations and output it
dt_new_user = {}
dt_all_deleted = {}
dt_nonused = {}
dt_all_nonused = {}
dt_all_inactive = {}

last_day_final_id = 0
yes_so_far = 0
no_so_far = 0.
nonused_so_far = 0
inactivated_so_far = 0
for dt in sorted_dt:
  # daily growth
  dt_new_user[dt] = dt_uid_cutoff[dt] - last_day_final_id
  last_day_final_id = dt_uid_cutoff[dt]
  # deleted
  yes_so_far += dt_num_yes[dt]
  no_so_far += dt_num_no[dt]
  percent_deleted = no_so_far/(no_so_far+yes_so_far)
  dt_all_deleted[dt] = dt_uid_cutoff[dt]*percent_deleted
  # non-used
  dt_nonused[dt] = dt_new_user[dt] * float(dt_nonactive[dt]) / dt_num_yes[dt]
  nonused_so_far += dt_nonused[dt]
  dt_all_nonused[dt] = nonused_so_far
  # inactivated
  inactivated_so_far += dt_inactivation[dt]
  percent_inactive = float(inactivated_so_far)/(yes_so_far+no_so_far) 
  dt_all_inactive[dt] = dt_uid_cutoff[dt] * percent_inactive

##### output everything...
items = (dt_uid_cutoff, dt_new_user, dt_all_deleted,
         dt_nonused, dt_all_inactive,
         dt_num_yes, dt_num_no, dt_nonactive, dt_inactivation)
print '\t'.join(['date', 'total_user', 'new_user',
                 'deleted_user', 'nonused_user', 'inactive_user',
                 'user_sampled_exist', 'user_sampled_deleted',
                 'user_sampled_neveractive', 'user_sampled_inactivated'])
for dt in sorted_dt:
  print '\t'.join([dt] + [str(x[dt]) for x in items])
