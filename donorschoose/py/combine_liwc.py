#!/usr/bin/env python
"""
Combine project data and output from liwc (i.e. output of 
wordcount_liwc.py)
"""
import csv

projects = open('../data/projects.csv')
liwc = open('../data/liwc_out')
out = open('../data/combined2.csv', 'w')

proj_head = projects.readline().strip().split(',')
liwc_head = liwc.readline().strip().split('\t')
header = proj_head + liwc_head[1:]
out.write('\t'.join(header) + '\n')

for proj in csv.reader(projects):
  wc = liwc.readline().strip().split('\t')
  if not proj[0] == wc[0]:
    print 'project ids %s and %s do not match' % (proj[0], wc[0])
    exit(0)
  proj += wc[1:]
  out.write('\t'.join(proj) +'\n')

