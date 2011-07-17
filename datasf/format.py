import csv
from collections import defaultdict

data = open("DataSF_DataSetList.csv")
datasets = {}
tagset = defaultdict(lambda:[])
for line in csv.reader(data):
  id, agency, _, email, cat, name, desc, loc, tag, _, _, _, _, _, _, _ = line
  tag = [x.strip() for x in tag.split(',')]
  datasets[id] = {'a': agency, 'e':email, 'c':cat, 'n':name, 't':tag}
  for t in tag:
    tagset[t].append(id)

tags = [t for t, c in tagset.items() if len(c) > 1 and t]
tagids = dict(zip(tags, range(len(tags))))

links = []
for tag in tags:
  ids = tagset[tag]
  other = [x for id in ids for x in datasets[id]['t'] if tagids.has_key(x)]
  links += [(tagids[tag], tagids[o]) for o in other]

links_cleaned = defaultdict(lambda: 0)
for link in links:
  if link[0] != link[1]:
    links_cleaned[link]+=1

node_txt = '\n'.join('{nodeName:"%s", group:1},' % tag for tag in tags)
#print node_txt

link_txt = '\n'.join('{source:%d, target:%d, value:%d},' % (link[0], link[1], val)
                     for link, val in links_cleaned.items())
print link_txt
