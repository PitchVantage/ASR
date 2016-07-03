#!/usr/bin/env python
#/usr/local/bin
#!/usr/bin/python

import re, locale
import sys
from collections import Counter

#Script: Replace_w_XYZ.py
#Author: Megan Willi
#Last Updated: 04_18_16

#Purpose: Reads in a clean, upper case, formatted lm transcript and replaces any words not in the lexicon with XYZ. Outputs a lm transcript file where any word not in the lexicon is replaced by XYZ.

#Command Line: ./Replace_w_XYZ.py [path/to/lexicon/file] [path/to/CLEAN_transcripts/file] [path/to/output/transcripts/file]

#Example Command Line: ./Replace_w_XYZ.py lexicon.txt CLEAN_transcript.txt output_transcript.txt

#Command Line Variables:
#sys.argv[1]= lexicon.txt
#sys.argv[2]= CLEAN_transcript.txt
#sys.argv[3]= output_transcript.txt

#Reads in lexicon .txt file.
f = open(sys.argv[1], "rb")

#Creates a counter of words in the lexicon
cLex = Counter()
for line in f:
    #May need to change to "\t" or whatever as needed. Check format of lexicon.txt.
   line_split = line.split(" ")
   id = line_split[0]
   cLex[id]+=1
f.close()

#For each word in the transcript, if it is NOT in the lexicon, then replace with XYZ. Write to an output.txt file.
f = open(sys.argv[2], "rb")
f3= open(sys.argv[3], "wb")
for line in f:
    NEW_line=[]
    line_split = line.rstrip().split(" ")
    for token in line_split:
        if not cLex[token]:
            NEW_line.append("XYZ")
        else:
            NEW_line.append(token)
    Sentence=" ".join(NEW_line)
    f3.write(Sentence+"\n")
f.close()
f3.close()



