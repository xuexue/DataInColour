#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
Given text, count the number (or percent) of words in each LIWC category
'''
from collections import defaultdict 
from nltk import wordpunct_tokenize
from math import log

class TFIDF:
  TF = 0
  DF = 1
  TFIDF = 2
  def __init__(self):
    self.wc = defaultdict(lambda: [0,0,0])
    self.docs = 0.0
  def process(self, text):
    tokens = [x for x in wordpunct_tokenize(text.lower()) if x.isalpha()]
    for word in set(tokens):
      self.wc[word][self.DF] += 1
    for word in tokens:
      self.wc[word][self.TF] += 1
    self.docs += 1
  def done(self):
    for token, arr in self.wc.items():
      arr[self.TFIDF] = arr[self.TF]*log(self.docs / arr[self.DF])
  def highest(self, n):
    return [(x[0], x[1][self.TFIDF]) for x in
            sorted(self.wc.items(),
                   key=lambda x: x[1][self.TFIDF], reverse=True)[:n]]

if __name__ == '__main__':
  x = TFIDF()
  x.process('hello world')
  x.process('hello wo')
  x.process('hello wo 2')
  x.done()
  print x.highest(2)

