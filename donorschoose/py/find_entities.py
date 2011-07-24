#!/usr/bin/env python
"""
get named entities from essays using captialization
"""
import csv
import nltk
import re
from collections import defaultdict

entities = defaultdict(lambda:[0,0])
TF = 0
DF = 1

stopwords = set(nltk.corpus.stopwords.words('english'))
def stopwd(tok):
  return tok.lower() in stopwords

bad_re = re.compile(r"(&#(\w)+?;|-{2,}|\*+)")
space_re = re.compile('\s+')
def clean(string):
  string = bad_re.sub(' ', string).replace('\\n', ' ').replace('\\r', ' ')
  string = space_re.sub(' ', string)
  return string

(_projectid,_teacher_acctid,title,short_description,need_statement,essay,
 paragraph1,paragraph2,paragraph3,paragraph4) = range(10)
essays = open('../data/essays.csv')
essays.readline() # header

sofar = []
for line in csv.reader(essays):
  for sentence in line[short_description:]: 
    tokens = nltk.word_tokenize(clean(sentence))
    newents = set()
    for tok in tokens:
      done = True
      if tok.isalpha() and (tok[0].isupper() or (not sofar and stopwd(tok))):
        sofar.append(tok)
        done = False
      if done:
        while( len(sofar)>1 and stopwd(sofar[0])):
          sofar = sofar[1:]
        while( len(sofar)>1 and stopwd(sofar[-1])):
          sofar = sofar[:-1]
        if len(sofar) > 1:
            newent = ' '.join(sofar)
            newent = newent.lower()
            newents.add(newent)
            entities[newent][TF] += 1
        sofar = []
    for newent in newents:
      entities[newent][DF] += 1

for ent, cnt in sorted(entities.items(), key=lambda x: x[1]):
  tf, df = cnt
  print '%s\t%d\t%d' % (ent, tf, df)
