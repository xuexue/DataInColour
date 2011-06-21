#!/usr/bin/env python
"""
Read data dump from mysql of donations merged projects table, and returns
donor-specific data.

Only donors who first donated between 2004-2008 and donations between 
2004-onwards are used.
"""

import datetime
import sys
import time 

from collections import defaultdict

(_donationid, _projectid, _donor_acctid, _cartid, donor_city, donor_state, donor_zip, is_teacher_acct, donation_timestamp, dollar_amount, donation_included_optional_support, payment_method, payment_included_acct_credit, payment_included_campaign_gift_card, payment_included_web_purchased_gift_card, via_giving_page, for_honoree, thank_you_packet_mailed, _projectid, _teacher_acctid, _schoolid, school_ncesid, school_latitude, school_longitude, school_city, school_state, school_zip, school_metro, school_district, school_county, school_charter, school_magnet, school_year_round, school_nlns, school_kipp, school_charter_ready_promise, teacher_prefix, teacher_teach_for_america, teacher_ny_teaching_fellow, primary_focus_subject, primary_focus_area, secondary_focus_subject, secondary_focus_area, resource_usage, resource_type, poverty_level, grade_level, vendor_shipping_charges, sales_tax, payment_processing_charges, fulfillment_labor_materials, total_price_excluding_optional_support, total_price_including_optional_support, students_reached, used_by_future_students, total_donations, num_donors, eligible_double_your_impact_match, eligible_almost_home_match, funding_status, date_posted, date_completed, date_thank_you_packet_mailed, date_expiration) = range(64)

class Donor:
  def __init__(self, line):
    self.id = line[_donor_acctid]
    self.n = 0
    self.n_thank = 0
    self.same_state = 0
    self.diff_state = 0
    self.avg_bw = 0.0
    # payment
    self.pay_none = 0
    self.pay_credit = 0
    self.pay_paypal = 0
    self.pay_check= 0
    self.pay_amazon= 0
    self.payacct_credit = 0
    self.payweb_gift = 0
    self.paycamp_gift = 0
    # page
    self.viagiving = 0
    # grade 
    self.grade_0 = 0
    self.grade_3 = 0
    self.grade_6 = 0
    self.grade_9 = 0
    # pov 
    self.pov_high = 0
    self.pov_low = 0
    self.pov_min = 0
    self.pov_unknown = 0
    # amt
    self.amt0 = 0
    self.amt10 = 0
    self.amt100 = 0
    # area
    self.music = 0
    self.lit = 0
    self.matsci = 0
    self.spe = 0
    self.app = 0
    self.hist = 0
    self.hea = 0
    # school
    self.city = line[donor_city]
    self.state = line[donor_state]
    self.zip = line[donor_zip]
    self.teacher = int(line[is_teacher_acct] == "true")
    self.thank1 = int(line[thank_you_packet_mailed] == "true")
    ts = self.gettime(line[donation_timestamp])
    self.ts1 = ts
    self.mo1 = ts.month
    self.wk1 = ts.weekday()
    self.prev = ts # tmp var
    self.shared(line)
  def gettime(self, ts):
    x = time.strptime(ts, '%Y-%m-%d %H:%M:%S')
    x = datetime.datetime(x.tm_year, x.tm_mon, x.tm_mday,
                          x.tm_hour, x.tm_min, x.tm_sec)
    return x
  def donation(self, line):
    ts = self.gettime(line[donation_timestamp])
    if (ts - self.ts1).days > 365*2:
      return 
    td = self.prev - ts
    self.avg_bw = float(self.avg_bw * self.n + td.days)/(self.n+1)
    self.prev = ts
    if line[donor_zip] != "":
      self.zip = line[donor_zip]
    if line[donor_city] != "":
      self.city = line[donor_city]
    if line[donor_state] != "":
      self.state = line[donor_state]
    self.shared(line)
  def shared(self, line):
    if self.state != "":
      if line[school_state] == self.state:
        self.same_state += 1
      else:
        self.diff_state += 1
    self.n_thank += int(line[thank_you_packet_mailed] == "true")
    self.amt0 += int(line[dollar_amount] == "under_10")
    self.amt10 += int(line[dollar_amount] == "10_to_100")
    self.amt100 += int(line[dollar_amount] == "100_and_up")
    self.music += int(line[primary_focus_area] == "Music & The Arts")
    self.lit += int(line[primary_focus_area] == "Literacy & Language")
    self.matsci += int(line[primary_focus_area] == "Math & Science")
    self.spe += int(line[primary_focus_area] == "Special Needs")
    self.app += int(line[primary_focus_area] == "Applied Learning")
    self.hist += int(line[primary_focus_area] == "History & Civics")
    self.hea += int(line[primary_focus_area] == "Health & Sports")

    # payment
    self.pay_none += self.eq(line, payment_method, 'no_cash_received')
    self.pay_credit += self.eq(line, payment_method, 'creditcard')
    self.pay_paypal += self.eq(line, payment_method, 'paypal')
    self.pay_check += self.eq(line, payment_method, 'check')
    self.pay_amazon+= self.eq(line, payment_method, 'amazon')
    self.payacct_credit += self.eq(line, payment_included_acct_credit, 'true')
    self.payweb_gift += self.eq(line, payment_included_web_purchased_gift_card, 'true')
    self.paycamp_gift += self.eq(line, payment_included_campaign_gift_card, 'true')
    # page
    self.viagiving  += self.eq(line, via_giving_page, 'true')
    # grade 
    self.grade_0 +=int(line[grade_level][-2:] == '-2')
    self.grade_3 +=int(line[grade_level][-1] == '5')
    self.grade_6 +=int(line[grade_level][-1] == '8')
    self.grade_9 +=int(line[grade_level][-2:] == '12')
    # pov 
    self.pov_high += self.eq(line, poverty_level, 'high')
    self.pov_low += self.eq(line, poverty_level, 'low')
    self.pov_min += self.eq(line, poverty_level, 'minimal')
    self.pov_unknown += self.eq(line, poverty_level, 'unknown')

    self.n += 1
  def eq(self, line, num, val):
    return int(line[num] == val)
  def list(self):
    lst = [self.id, self.state, self.n, 
      self.teacher, self.thank1, self.n_thank, self.ts1, self.mo1,
      self.wk1, self.avg_bw,
      self.amt0, self.amt10, self.amt100, self.music, self.lit,
      self.matsci, self.spe, self.app, self.hist, self.hea,
      self.same_state, self.diff_state,

      self.pay_none, self.pay_credit, self.pay_paypal,
      self.pay_check, self.pay_amazon, self.payacct_credit,
      self.payweb_gift, self.paycamp_gift, self.viagiving,
      self.grade_0, self.grade_3, self.grade_6,
      self.grade_9, self.pov_high, self.pov_low,
      self.pov_min, self.pov_unknown,
      ]
    return lst

donotuse = set()
donors = {}
sys.stdin.readline()
for line in sys.stdin:
  line = line.split('\t')
  id = line[_donor_acctid]
  if line[dollar_amount] == 'WY':
    continue
  yr = int(line[donation_timestamp][:4]) 
  # assumption: data is ordered chronologically
  if yr < 2004:
    donotuse.add(id)
    if donors.get(id) is not None:
      del donors[id]
    continue
  elif id in donotuse:
    continue
  elif yr > 2008 and not donors.has_key(id):
    continue

  donor = donors.get(id)
  if donor is not None:
    donor.donation(line)
  else:
    donors[id] = Donor(line)

header = ['id', 'state', 'n', 'isteacher',
          'thank_first', 'n_thank', 'first', 'first_mo',
          'first_wk', 'time_bw_don', 'amt_0', 'amt_10',
          'amt_100', 'music', 'lit', 'mathsci', 'special',
          'applied', 'hist', 'health', 'samestate', 'diffstate',
          'pay_none', 'pay_credit', 'pay_paypal',
          'pay_chec', 'pay_amazo', 'payacct_credit',
          'payweb_gift', 'paycamp_gift', 'viagiving',
          'grade_0', 'grade_3', 'grade_6',
          'grade_9', 'pov_high', 'pov_low',
          'pov_min', 'pov_unknown',
          ]
print '\t'.join(header)
for id, donor in donors.items():
  print '\t'.join(str(x) for x in donor.list())
