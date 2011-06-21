#!/usr/bin/env python
"""
Get the top n words in product names with the highest TFIDF for a certain
type of projects

Ran with:
python get_tfidf_words.py --file=resource --tfidf=../data/resource_tfidf
python get_tfidf_words.py --file=resource --tfidf=../data/resource_tfidf --count=../data/resource_word
python get_tfidf_words.py --file=essay --tfidf=../data/essay_tfidf
python get_tfidf_words.py --file=essay --tfidf=../data/essay_tfidf --count=../data/essay_word
"""
import csv
import sys

from collections import defaultdict
from itertools import groupby
from nltk import wordpunct_tokenize
from optparse import OptionParser

from tfidf import TFIDF

def wordcount(filename, text):
  resources = open('../data/resources.csv')
  resources.readline() # header
  wordcount = TFIDF()
  for line in csv.reader(resources):
    wordcount.process(text(line).lower())
  wordcount.done()

  out = open(filename, 'w')
  for word, tfidf in wordcount.highest(200):
    out.write('%s\t%f\n' % (word, tfidf))

def writewords(tfidf, outfile, text, id):
  words = []
  for line in open(tfidf):
    words.append(line.split('\t')[0])
  words_set = frozenset(words)

  outfile = open(outfile, 'w')
  resources = open('../data/resources.csv')
  resources.readline() # header
  outfile.write('\t'.join(words) + '\n')
  for id, lines in groupby(csv.reader(resources), id):
    wc = defaultdict(lambda:0)
    for line in lines:
      for t in wordpunct_tokenize(text(line).lower()):
        if t in words_set:
          wc[t] = 1
    outfile.write('%s\t%s\n' % (id, '\t'.join(str(wc[word]) for word in words)))

if __name__ == '__main__':
  parser = OptionParser(usage='usage: %prog [options]\n\n'
                              'When only tfidf file is provided, program will'
                              'count tfidf. When both tfidf and count file'
                              'pats are provided, it will read the tfidf file'
                              'and do word counts')
  parser.add_option('--file', dest='file', default='resource',
                    help='do tfif on resource or essay?')
  parser.add_option('--tfidf', dest='tfidf', default='../data/tfidf',
                    help='file to write/read the TFIDF info')
  parser.add_option('--count', dest='gen', default=None,help='resource count')

  if len(sys.argv) == 1:
    parser.print_help()
    sys.exit(-1)
  (options,args) = parser.parse_args(sys.argv[1:])

  if options.file == 'resource':
    text = lambda line: line[5]
    id = lambda line: line[1]
  elif options.file == 'essay':
    text = lambda line: ' '.join(line[3:10])
    id = lambda line: line[0]
  else:
    print "Unknown file type!"
    exit(0);

  if options.gen is None:
    wordcount(options.tfidf, text)
  else:
    writewords(options.tfidf, options.gen, text, id)

