#!/usr/bin/env python
'''
Do teacher prefixes change at all?
Result: Nope.
'''
import csv
from collections import defaultdict

teachers = defaultdict(lambda: set())

projects = open('../data/projects.csv')
header = projects.readline().strip().split(',')
for proj in csv.reader(projects):
  acctid = proj[1]
  title = proj[18]
  teachers[acctid].add(title)

for id, titles in teachers.items():
  if len(titles) > 1:
    print id, titles
