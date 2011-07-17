#!/usr/bin/env python
"""
select data for a given district
"""
import csv
from sys import argv

district = argv[1]

proj_ids = []
projects = open('../data/projects.%s.csv' % district)
projects.readline().strip() # header
for proj in csv.reader(projects):
  proj_ids.append(proj[0])
proj_ids = frozenset(proj_ids)
projects.close()

essays = open('../data/essays.csv')
essay_out = open('../data/essays.%s.csv' % district, 'w')
essay_out.write(essays.readline()) # header
for line in essays:
  proj = line[1:line.find(',')-1]
  if proj in proj_ids:
    essay_out.write(line)
essays.close()
essay_out.close()

resources = open('../data/resources.csv')
resource_out = open('../data/resources.%s.csv' % district, 'w')
resource_out.write(resources.readline()) # header
for line in resources:
  proj = line.split(',')[1][1:-1]
  if proj in proj_ids:
    resource_out.write(line)
resources.close()
resource_out.close()


