import sys
from collections import Counter
import re

#method to calculate the percentage of NE's in a transcript file

#sys.argv[0] = transcript file

#python findPercentNE.py path/to/file.txt

#counters to hold tokens
ne = Counter()
non_ne = Counter()

f = open(sys.argv[1], "rb")

regex = r'^[0-9A-z]+.*'

for line in f:
    line_split = line.rstrip().split(" ")
    #if first item is utterance ID
    if re.match(regex, line):
        sentence = line_split[1:]
    #if there is no utterance ID
    else:
        sentence = line_split
    print(sentence)
    #for each idx in sentence
    for i in range(len(sentence)):
            word = sentence[i]
            #if it's not first word in sentence and is capitalized
            if i != 0 and word[0].isupper():
                ne[word] += 1
            else:
                non_ne[word] += 1


ne_count = sum(ne.values())
non_ne_count = sum(non_ne.values())

ne_rate = float(ne_count) / float(non_ne_count)

print("number of named entities", ne_count)
print("number of non named entities", non_ne_count)
print("percentage of named entities", ne_rate)

f.close()