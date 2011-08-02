#!/usr/bin/env python
# -*- coding: utf-8 -*- 
import codecs
import csv
import json

infile = 'data/usrs'
outfile = 'data/users.csv'

latest_tweet = 'status'
keys = []
status_keys = []

# read in the first line to determine the 
with codecs.open(infile, 'r', 'utf-8') as input:
  first = json.loads(input.readline().split('\t')[1])
  keys = [k for k in first.keys() if k != latest_tweet]
  tweet = first[latest_tweet]
  status_keys = tweet.keys()

#now doing this for real!
outfile = csv.writer(open(outfile, 'w'))
outfile.writerow(keys + status_keys)
for line in open(infile):
  usr, line = line.split('\t')
  if line.startswith('{'):
    js = json.loads(line)
    row = [js[k] for k in keys]
    if js.has_key(latest_tweet):
      row += [js[latest_tweet][k] for k in status_keys]
    else:
      row += ['null']*len(status_keys)
    row = map(lambda x: x if not isinstance(x,unicode) else x.encode('utf-8'), row)
    outfile.writerow(row)

