#!/usr/bin/env python
#/usr/local/bin
#!/usr/bin/python

import re, locale
import sys

#Script: Replace_w_XYZ_and_list_of_unknown_words.py
#Author: Megan Willi
#Last Updated: 05_2_16

#Purpose: Reads in a clean, upper case, formatted lm transcript and replaces any words not in the lexicon with XYZ. Outputs a lm transcript file where any word not in the lexicon is replaced by XYZ.

#Command Line: ./Replace_w_XYZ_and_list_of_unknown_words.py [path/to/lexicon/file] [path/to/CLEAN_transcripts/file] [path/to/output/transcripts/file] [path/to/output/unknown/words/list/file]

#Example Command Line: ./Replace_w_XYZ_and_list_of_unknown_words.py lexicon.txt CLEAN_transcript.txt output_transcript.txt output_unkown_words_list.txt

#Command Line Variables:
#sys.argv[1]= lexicon.txt
#sys.argv[2]= CLEAN_transcript.txt
#sys.argv[3]= output_transcript.txt
#sys.argv[4]= output_unknown_words_list.txt

#Reads in lexicon .txt file.
f = open(sys.argv[1], "rb")

#Creates a list of words in the lexicon.
Words=[]
for line in f:
    #May need to change to "\t" or whatever as needed. Check format of lexicon.txt.
   line_split = line.split(" ")
   id = line_split[0]
   Words.append(id)
f.close()

#For each word in the transcript, if it is NOT in the lexicon, then replace with XYZ. Write to an output.txt file.
f = open(sys.argv[2], "rb")
f3= open(sys.argv[3], "wb")
f4 = open(sys.argv[4], "wb")
for line in f:
    NEW_line=[]
    Unknown_words=[]
    line_split = line.rstrip().split(" ")
    for token in line_split:
        if token not in Words:
            NEW_line.append("XYZ")
            Unknown_words.append(token+"\n")
        else:
            NEW_line.append(token)
    Sentence=" ".join(NEW_line)
    Unknown = " ".join(Unknown_words)
    f3.write(Sentence+"\n")
    f4.write(Unknown)
f.close()
f3.close()
f4.close()
