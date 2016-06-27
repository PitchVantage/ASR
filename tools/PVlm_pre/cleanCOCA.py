"""
Cleans COCA.master file for use in kaldi language model

:param sys.argv[1] = location of master file
:param ays.argv[2] = location for output file
:param sys.argv[3] = minimum sentence length to keep
-removes dirty sentences (... or #)
-removes sentences with numbers in them
-removes sentences with less than sys.argv[3] tokens
-removes punctuation
-puts contractions back together

"""

import sys
import re
from nltk.tokenize import sent_tokenize
from nltk.tokenize import word_tokenize

#python cleanCoca.py path/to/coca.master path/to/coca.cleaned 5

fIn = open(sys.argv[1], "rb")
fOut = open(sys.argv[2], "wb")

#regex for punctuation
punctRegex = r'(\-\- )|(\: )|(\" )|(\' ?$)|(\' )|(\.\.\. )|(\, )|(\@ )|(\# [A-z]+\-[A-z]+ \: )|(.*\#.* )|( [\.\?\!] ?)'

#regex for sentences with #
poundRegex = r'.*\#.*'

#regex for sentences with numbers
numberRegex = r'.*[0-9].*'

#regex for finding contractions (after already uppercased)
contractRegex = r'(.*)? *([A-Z]+) {1,}([A-Z]*\'[A-Z]+) {1,}(.*)?'

#variable for counting lines (for progress)
c = 0

#iterate through each line
    # in the COCA master, each line is an entire recording with multiple sentences
    # that has already been cleaned to a certain extent.
for line in fIn:
    #tokenize into sentences
    sentences = sent_tokenize(line.rstrip())
    for sent in sentences:
        c += 1
        #if sentence doesn't contain a # sign or any numbers
        if not re.match(poundRegex, sent) and \
                not re.match(numberRegex, sent):
            #tokenize into words
            tokens = word_tokenize(sent)
            #ignore sentences with ... in them
            if "..." not in tokens and \
                " ..." not in tokens and \
                "... " not in tokens and \
                " ... " not in tokens:
                    #convert sentence to string and convert all to uppercase
                    sentUpper = " ".join(tokens).upper()
                    #filter out punctuation
                    sentUpperClean = re.sub(punctRegex, "", sentUpper)
                    noExtraSpace = re.sub(r' {2,}', "", sentUpperClean)
                    #join contractions
                    containsContraction = re.match(contractRegex, noExtraSpace)
                    if containsContraction:
                        contraction = re.sub(r'([A-Z]+) ([A-Z]*\'[A-Z]+)', "\\1\\2", noExtraSpace)
                    else:
                        contraction = noExtraSpace
                    #remove any duplicate spacing and print to fOut
                    if len(contraction.split(" ")) > int(sys.argv[3]):
                        fOut.write(contraction + "\n")
        if c % 5000 == 0:
            print("Processing line %s" %str(c))
fIn.close()
fOut.close()
