"""
Cleans an .stm file from a TEDLIUM transcript, writes to STDOUT

:param sys.argv[1] = full path to .stm file
-converts all to uppercase
-removes the metadata at front of line
-removes non word symbols in the text
-reconnects split contractions
"""

import sys
import re

#python cleanTEDLIUM.py path/to/stm/file.stm

fIn = open(sys.argv[1], "rb")

#regex for finding contractions (after already uppercased)
contractRegex = r'(.*)? *([A-Z]+) {1,}([A-Z]*\'[A-Z]+) {1,}(.*)?'

#regex for dropping () at end of a word
parenRegex = r'(.*)\(.*\)'

#string to keep
string_to_keep = ""

#iterate through each line
for line in fIn:
    split_line = line.rstrip().split(" ")
    #drop first 5 items (metadata we don't need)
    keep = split_line[6:]
    #iterate through each remaining word
    for i in range(len(keep)):
        word = keep[i]
        #skip non-words and contraction endings (already concatenated in previous word)
        if not word.startswith("{") \
        and not word.startswith("(") \
        and not word.startswith("<") \
        and word != "ignore_time_segment_in_scoring" \
        and not word.startswith("'"):
            #if word has (#) at end, strip it
            #convert to uppercase
            #if NEXT word starts with ', then collapse the two together
            if re.match(parenRegex, word):
                clean_word = re.match(parenRegex, word).group(1).upper()
            else:
                clean_word = word.upper()
            if i < len(keep) - 1 and keep[i+1].startswith("'"):
                next = keep[i+1].upper()
                # clean_word = clean_word + keep[i+1].upper()
                #if the contraction tail has (2) attached
                clean_word = clean_word + next
                if re.match(parenRegex, clean_word):
                    clean_word = re.match(parenRegex, clean_word).group(1).upper()
            if string_to_keep == "":
                string_to_keep += clean_word
            else:
                string_to_keep += " " + clean_word

print(string_to_keep)
