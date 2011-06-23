#!/usr/bin/env python
"""
Combine project data and output from liwc and other scripts
"""
import csv

projects = open('../data/projects.csv')
otherfiles = {''     :open('../data/liwc_out'),
              #'resource_' :open('../data/resource_word'),
              'essay_'    :open('../data/essay_word')}

out = open('../data/combined2.csv', 'w')

header = projects.readline().strip().split(',')
for name, file in otherfiles.items():
  header += ['%s%s' % (name, head) for head in
             file.readline().strip().split('\t')[1:]]
out.write('\t'.join(header) + '\n')

for proj in csv.reader(projects):
  for name, file in otherfiles.items():
    more = file.readline().strip().split('\t')
    if not proj[0] == more[0]:
      print 'project ids %s and %s do not match in file %s' % (proj[0], more[0], name)
      exit(0)
    proj += more[1:]
  out.write('\t'.join(proj) +'\n')
