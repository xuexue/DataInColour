#!/usr/bin/env python
import csv
from sys import argv

file = open(argv[1])
file.readline()

for line in csv.reader(file):
  print '%s:%d' % (line[1], float(line[5])*100)
