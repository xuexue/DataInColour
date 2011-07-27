#!/usr/bin/env python
"""
select data from 2011 onwards
"""
import csv

from collections import defaultdict
from string import punctuation
from sys import argv

from get_tfidf_words import get_entities
from tfidf import TFIDF

def count(district):
  (_projectid,_teacher_acctid,_schoolid,school_ncesid,school_latitude,school_longitude,school_city,school_state,school_zip,school_metro,school_district,school_county,school_charter,school_magnet,school_year_round,school_nlns,school_kipp,school_charter_ready_promise,teacher_prefix,teacher_teach_for_america,teacher_ny_teaching_fellow,primary_focus_subject,primary_focus_area,secondary_focus_subject,secondary_focus_area,resource_usage,resource_type,poverty_level,grade_level,vendor_shipping_charges,sales_tax,payment_processing_charges,fulfillment_labor_materials,total_price_excluding_optional_support,total_price_including_optional_support,students_reached,used_by_future_students,total_donations,num_donors,eligible_double_your_impact_match,eligible_almost_home_match,funding_status,date_posted,date_completed,date_thank_you_packet_mailed,date_expiration) = range(46)
  proj_ids = []
  projects = open('../data/projects.%scsv' % district)
  projects.readline().strip() # header
  for proj in csv.reader(projects):
    if proj[date_posted].startswith('2011'):
      proj_ids.append(proj[0])
  proj_ids = frozenset(proj_ids)
  projects.close()

  wordcount = TFIDF(get_entities(ent_file))
  essays = open('../data/essays.%scsv' % district)
  essays.readline() # header
  for line in csv.reader(essays):
    if line[0] in proj_ids:
      text = ' '.join(line[3:10]).lower()
      wordcount.process(text)
  wordcount.done()
  essays.close()

  out = open('../data/wc_%scsv' % district, 'w')
  for word, tf, df, tfidf in wordcount.highest(0):
    out.write('%s\t%f\t%f\t%f\n' % (word, tf, df, tfidf))

def merge(files):
  words = {}
  for file in files[1:]:
    words[file] = defaultdict(lambda: (0,0))
    input = open(file)
    for line in input:
      word, tf, df, _ = line.split('\t')
      words[file][word] = (float(tf), float(df))

  input = open(files[0])
  outfile = open('../data/wc_merged.tsv', 'w')
  for line in input:
    word, tf, df, _ = line.split('\t')
    if not any(word.endswith(x) or word.startswith(x) for x in punctuation):
      output = [word, tf, df] + [n for file, dat in words.items() for n in dat[word]]
      outfile.write('\t'.join(str(x) for x in output)+'\n')

if __name__ == '__main__':
  ent_file = '../data/my_entities'
  func = argv[1]

  if func == 'count':
    district = '' if len(argv) == 2 else argv[2]+'.'
    count(district)
  elif func == 'merge':
    merge(['../data/wc_csv', '../data/wc_memphis.csv', '../data/wc_tampa.csv'])
  

