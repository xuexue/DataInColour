#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
Given text, count the number (or percent) of words in each LIWC category
'''

from nltk import wordpunct_tokenize
from collections import defaultdict

########## PREPARATORY SHIT 

liwc_folder = sys.argv[1]
_YEAR = '2007'
_CATFILE = '%s/liwccat%d.txt' % (liwc_folder, _YEAR)
_DICTFILE = '%s/liwcdic%d.dic' % (liwc_folder, _YEAR)

class Dictionary:
  def __init__(self, letter):
    self.letter = letter
    self.children = {}
    self.cats = []
  def addcats(self, cats):
    self.cats = cats
  def addchild(self, word, cats):
    if len(word) == 0:
      self.addcats(cats)
    else:
      child = self.children.get(word[0])
      if child is None:
        child = Dictionary(word[0])
        self.children[word[0]] = child
      child.addchild(word[1:], cats)
  def getchild(self, l):
    child = self.children.get(l)
    if child is None:
      child = self.children.get('*')
    return child
  def get(self, word):
    if self.letter == '*':
      return self.cats
    if word == '':
      if len(self.cats) > 0:
        return self.cats
      star = self.getchild('*')
      if star is not None:
        return star.cats
      return None
    child = self.getchild(word[0])
    if child is not None:
      return child.get(word[1:])
    return None

########## READ IN CATEGORIES AND DICTIONARY

categories = {}
for r in open(_CATFILE):
  if r.find('%') < 0:
    id, name = r.rstrip('\n\t ').split('\t')
    categories[id] = name.split('@')[0]
dictionary = Dictionary('')
for line in open(_DICTFILE):
  w = line.rstrip('\n\t ').split('\t')
  dictionary.addchild(w[0], w[1:])

########## COUNTING WORDS, FOR REAL

def header():
  return categories.values() + ['n']

def divide_words(counts):
  nwords = counts['n']
  for cat in header():
    if cat != 'n':
      counts[cat] = float(counts[cat])/nwords

def countcat(words, ret="list", divide=False):
  # tokenize
  words = wordpunct_tokenize(words.lower().replace('\'',''))
  # iterate through all words
  counts = defaultdict(lambda:0)
  for word in words:
    if word.isalpha():
      counts['n'] += 1

      cats = dictionary.get(word)
      if cats is not None:
        for cat in cats:
          counts[categories[cat]] += 1

  if divide:
    divide_words(counts)

  if ret == "dict":
    return counts
  return map(lambda n: counts[n], header())

def countall(text):
  counts = []
  for line in text:
    count = countcat(line)
    counts.append(count)
  return counts
