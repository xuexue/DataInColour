#!/usr/bin/env python
"""
Read data dump from mysql of donations merged projects table, and returns
data about the first time a donor made a donation, and whether or not s/he
returned.

Only donors who first donated between 2004-2008 and donations between 
2004-onwards are used.
"""

import time 
import datetime
import sys
import csv

from collections import defaultdict

(_donationid, _projectid, _donor_acctid, _cartid, donor_city, donor_state, donor_zip, is_teacher_acct, donation_timestamp, dollar_amount, donation_included_optional_support, payment_method, payment_included_acct_credit, payment_included_campaign_gift_card, payment_included_web_purchased_gift_card, via_giving_page, for_honoree, thank_you_packet_mailed, _teacher_acctid, _schoolid, school_ncesid, school_latitude, school_longitude, school_city, school_state, school_zip, school_metro, school_district, school_county, school_charter, school_magnet, school_year_round, school_nlns, school_kipp, school_charter_ready_promise, teacher_prefix, teacher_teach_for_america, teacher_ny_teaching_fellow, primary_focus_subject, primary_focus_area, secondary_focus_subject, secondary_focus_area, resource_usage, resource_type, poverty_level, grade_level, vendor_shipping_charges, sales_tax, payment_processing_charges, fulfillment_labor_materials, total_price_excluding_optional_support, total_price_including_optional_support, students_reached, used_by_future_students, total_donations, num_donors, eligible_double_your_impact_match, eligible_almost_home_match, funding_status, date_posted, date_completed, date_thank_you_packet_mailed, date_expiration) = range(63)


projects = {}
for line in csv.reader(open('../data/projects.csv')):
    projects[line[0]] = line[1:]

class Donor:
  def __init__(self, line):
    self.line = line + projects[line[1]]
    self.first = self.gettime(line[8])
    self.line.append(0)
  def second(self, line):
    ts = self.gettime(line[8])
    if (ts-self.first).days <= 365:
      self.line[-1] += 1
  def gettime(self, ts):
    x = time.strptime(ts[:19], '%Y-%m-%d %H:%M:%S')
    x = datetime.datetime(x.tm_year, x.tm_mon, x.tm_mday,
                          x.tm_hour, x.tm_min, x.tm_sec)
    return x

donotuse = set()
donors = {}
for line in sys.stdin:
  line = line.strip().split('\t')
  id = line[_donor_acctid]
  if line[dollar_amount] == 'WY':
    continue
  yrmo = line[donation_timestamp][:7] 
  # assumption: data is ordered chronologically
  if yrmo < '2004-01':
    donotuse.add(id)
  elif id in donotuse:
    continue
  elif yrmo >= '2010-05' and not donors.has_key(id):
    continue

  donor = donors.get(id)
  if donor is not None:
    donor.second(line)
  else:
    donors[id] = Donor(line)

header = ('_donationid', '_projectid', '_donor_acctid', '_cartid', 'donor_city', 'donor_state', 'donor_zip', 'is_teacher_acct', 'donation_timestamp', 'dollar_amount', 'donation_included_optional_support', 'payment_method', 'payment_included_acct_credit', 'payment_included_campaign_gift_card', 'payment_included_web_purchased_gift_card', 'via_giving_page', 'for_honoree', 'thank_you_packet_mailed', '_teacher_acctid', '_schoolid', 'school_ncesid', 'school_latitude', 'school_longitude', 'school_city', 'school_state', 'school_zip', 'school_metro', 'school_district', 'school_county', 'school_charter', 'school_magnet', 'school_year_round', 'school_nlns', 'school_kipp', 'school_charter_ready_promise', 'teacher_prefix', 'teacher_teach_for_america', 'teacher_ny_teaching_fellow', 'primary_focus_subject', 'primary_focus_area', 'secondary_focus_subject', 'secondary_focus_area', 'resource_usage', 'resource_type', 'poverty_level', 'grade_level', 'vendor_shipping_charges', 'sales_tax', 'payment_processing_charges', 'fulfillment_labor_materials', 'total_price_excluding_optional_support', 'total_price_including_optional_support', 'students_reached', 'used_by_future_students', 'total_donations', 'num_donors', 'eligible_double_your_impact_match', 'eligible_almost_home_match', 'funding_status', 'date_posted', 'date_completed', 'date_thank_you_packet_mailed', 'date_expiration')

print '\t'.join(header)
for id, donor in donors.items():
  print '\t'.join(str(x) for x in donor.line)
