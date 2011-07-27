#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
Given text, count the number (or percent) of words in each LIWC category
'''
import re
import string
import nltk

from collections import defaultdict 
from nltk import word_tokenize 
from math import log

class TFIDF:
  TF = 0
  DF = 1
  TFIDF = 2
  bad_re = re.compile(r"(&#(\w)+?;|-{2,}|\*+)")
  space_re = re.compile('\s+')
  stopwords = set(nltk.corpus.stopwords.words('english'))

  def __init__(self, entities):
    self.wc = defaultdict(lambda: [0,0,0])
    self.docs = 0.0
    self.entity_start = defaultdict(lambda:defaultdict(lambda:[]))
    for ent in entities:
      splitted = ent.split(' ')
      self.entity_start[splitted[0]][len(splitted)].append(ent)
  def tokenize(self, text):
    text = self.bad_re.sub(' ', text).replace('\\n', ' ').replace('\\r', ' ')
    text = self.space_re.sub(' ', text)
    potential = word_tokenize(text)
    if not self.entity_start: # no entity list => can't extract entities
      return potential
    # merge entities
    tokens = [] # real tokens with entities merged
    skip = 0    # keep track of number of tokens to skip
    for i, tok in enumerate(potential):
      if skip > 0: # already added the word as part of an entity
        skip -= 1
        continue
      for n, ents in sorted(self.entity_start[tok].items(), reverse=True):
        # n = length of entities in words (or number of tokens)
        # ents = a list of tokens of length n starting with tok
        if skip > 0: # already found an entity
          break
        potential_ent = ' '.join(potential[i:i+n])
        for ent in ents:
          if potential_ent == ent: # compare
            tokens.append(ent)
            skip = n - 1 # skip the next few words
            break
      if skip == 0: # no entity => add the single token
        if any(l.isalpha() for l in tok) and tok not in self.stopwords:
          tokens.append(tok)
    return tokens # yay!
  def process(self, text):
    tokens = self.tokenize(text.lower())
    if not tokens:
      return
    weight = 1.0/len(tokens)
    for word in set(tokens):
      self.wc[word][self.DF] += 1
    for word in tokens:
      self.wc[word][self.TF] += weight
    self.docs += 1
  def done(self):
    for token, arr in self.wc.items():
      arr[self.TFIDF] = arr[self.TF]*log(self.docs / arr[self.DF])
  def highest(self, n):
    if n == 0:
      n = len(self.wc)
    else:
      n = min(n, len(self.wc))
    return [(x[0], x[1][self.TF], x[1][self.DF], x[1][self.TFIDF])
            for x in sorted(self.wc.items(),
                            key=lambda x: x[1][self.TFIDF], reverse=True)[:n]]

if __name__ == '__main__':
  x = TFIDF()
  x.process('hello world')
  x.process('hello wo')
  x.process('hello wo 2')
  x.done()
  print x.highest(2)

