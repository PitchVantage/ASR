#!/usr/bin/env python
#/usr/local/bin
#!/usr/bin/python
import re, locale
import sys

#Script: UpperCase_Dict.py
#Author: Megan Willi
#Last Updated: 04_20_16

#Purpose: Reads in an unformatted, lower case lexicon.txt file and outputs an uppercase lexicon.txt file.

#Command Line: ./UpperCase_Dict.py [path/to/input/file] [path/to/output/file]

#Example Command Line: ./UpperCase_Dict.py TEDLIUM.150K.txt Finished/lexicon.txt

#Command Line Variables:
#sys.argv[1]= lexicon.txt
#sys.argv[2]= output_lexicon.txt


f = open(sys.argv[1], "rb")

ALL=""
sentence=[]
for line in f:
    line=line.upper()
    ALL=ALL+line

ALL_final=str(ALL)
#print ALL_final

with open(sys.argv[2], 'wb') as f:
    f.write(ALL_final)
f.close()

