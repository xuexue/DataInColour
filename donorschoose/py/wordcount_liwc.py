#!/usr/bin/env python
from liwc import countcat, header
import csv
"""
Combine project data and output from liwc (i.e. output of 
wordcount_liwc.py)
"""
(_projectid,_teacher_acctid,title,short_description,need_statement,essay,
 paragraph1,paragraph2,paragraph3,paragraph4) = range(10)

essays = open('../data/essays.csv')
out = open('../data/liwc_out', 'w')

headers = ['_projectid'] + header()
out.write('\t'.join(headers) + '\n')
essays.readline() # get rid of headers
for line in csv.reader(essays):
  lst = countcat(' '.join(line[short_description:]))
  out.write('\t'.join(str(x) for x in [line[_projectid]] + lst) + '\n')

