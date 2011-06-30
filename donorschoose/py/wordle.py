#!/usr/bin/env python
"""
Get the top n words in product names with the highest TFIDF for a certain
type of projects
"""
import csv
import inflect
import random
import sys

from optparse import OptionParser

(_projectid,_teacher_acctid,_schoolid,school_ncesid,school_latitude,school_longitude,school_city,school_state,school_zip,school_metro,school_district,school_county,school_charter,school_magnet,school_year_round,school_nlns,school_kipp,school_charter_ready_promise,teacher_prefix,teacher_teach_for_america,teacher_ny_teaching_fellow,primary_focus_subject,primary_focus_area,secondary_focus_subject,secondary_focus_area,resource_usage,resource_type,poverty_level,grade_level,vendor_shipping_charges,sales_tax,payment_processing_charges,fulfillment_labor_materials,total_price_excluding_optional_support,total_price_including_optional_support,students_reached,used_by_future_students,total_donations,num_donors,eligible_double_your_impact_match,eligible_almost_home_match,funding_status,date_posted,date_completed,date_thank_you_packet_mailed,date_expiration) = range(46)
(resourceid,_projectid2,vendorid,vendor_name,project_resource_type,item_name,
 item_number,item_unit_price,item_quantity) = range(9)


# read in the list of "good" projects
def main(area, type, pref, frac, file):
  projects = open('../data/projects.csv')
  projects.readline() # header
  good_projects = []

  allarea = 'all' in area
  alltype = 'all' in type
  allpref = 'all' in pref
  
  for line in csv.reader(projects):
    if (line[date_posted].startswith("2010") and 
        (allarea or line[primary_focus_area] in area) and 
        (allpref or line[teacher_prefix] in pref) and 
        (alltype or line[resource_type] in type)):
      good_projects.append(line[_projectid])
  good_projects = frozenset(good_projects)

  p = inflect.engine() # for de-pluralizing words
  out = open(file, 'w')
  resources = open('../data/resources.csv')
  resources.readline() # header
  for line in csv.reader(resources):
    if line[_projectid2] in good_projects:
      text = line[item_name]
      for x in text.strip().lower().replace('&#8217;', '').split():
        word = x
        try:
          word = p.singular_noun(x)
        except:
          pass
        if not word:
          word = x
        if random.random() < frac:
          out.write('%s ' %  word)

if __name__ == '__main__':
  parser = OptionParser()
  parser.add_option('--file', dest='file', default='wordle',
                    help='output file path')
  parser.add_option('--area', dest='area', default='all',
                    help='primary focus area (replace space with _, separate'
                         'by commas)')
  parser.add_option('--type', dest='type', default='all',
                    help='resource type (replace space with _, separate'
                         'by commas)')
  parser.add_option('--pref', dest='pref', default='all',
                    help='teacher prefix (replace space with _, separate'
                         'by commas)')
  parser.add_option('--subset', dest='subset', default=1, type='float',
                    help='fraction to take')

  if len(sys.argv) == 1:
    parser.print_help()
    sys.exit(-1)
  (options,args) = parser.parse_args(sys.argv[1:])

  main(options.area.replace('_', ' ').split(','),
       options.type.replace('_', ' ').split(','),
       options.pref.replace('_', ' ').split(','),
       options.subset,
       options.file)
