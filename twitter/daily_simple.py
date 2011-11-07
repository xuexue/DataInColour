#!/usr/bin/env python
# -*- coding: utf-8 -*- 
'''Just get the number of new users per day in a robust way.'''

import codecs
import csv
import time
from datetime import date
from collections import defaultdict

sorted_input = open('data/sorted.csv')
header = sorted_input.readline().split(',')
id = header.index('id')
created_at = header.index('created_at')   # creation date
tcreated_at = header.index('tcreated_at') # last tweet

dt_min_uid = {}
dt_max_uid = {}
first_dt = None
first = True

n = 0
for line in csv.reader(sorted_input):
  if n > 10000:
    break
  n+=1

n = 0
for line in csv.reader(sorted_input):
  n+=1
  # create the date
  dt = time.strptime(line[created_at].replace('+0000 ', ''))
  dt = date(dt.tm_year, dt.tm_mon, dt.tm_mday)
  if not first_dt:
    first_dt = dt
  day_id = (dt - first_dt).days

  line[id] = int(line[id])
  if not dt_min_uid.get(day_id):
    dt_min_uid[day_id] = line[id]
  dt_max_uid[day_id] = line[id]

  # test the "good" cases first, for now
  if n > 50000:
    break

lower_estimate = []
upper_estimate = []

for i in sorted(dt_min_uid.keys())[1:]:
  lower_estimate.append(dt_max_uid[i] - dt_min_uid[i])
  upper_estimate.append(dt_min_uid[i+1] - dt_max_uid[i-1])
  print lower_estimate[i-1], upper_estimate[i-1]
