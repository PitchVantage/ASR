import re, locale
import sys

#Script: Remove_Duplicates_Lexicon.py
#Author: Megan Willi
#Last Updated: 05_04_16

#Purpose: Reads file (i.e. phones list or lexicon) with duplicates and outputs file without duplicates.

#Command Line: ./Remove_Duplicates_Lexicon.py [path/to/lexicon/file] [path/to/output/lexicon/file]
#Example Command Line: ./Remove_Duplicates_Lexicon.py lexicon.txt CLEAN_lexicon.txt

#Command Line Variables:
#sys.argv[1]= lexicon.txt
#sys.argv[2]= CLEAN_lexicon.txt

#Reads in lexicon .txt file.
f = open(sys.argv[1], "rb")

#Creates a list of words in the lexicon.
Words=[]
for line in f:
   Words.append(line)
f.close()

Good=list(set(Words))

f2= open(sys.argv[2], "wb")
for j in Good:
    f2.write(j)
f2.close()



