import sys
import ast
import gzip
from collections import Counter

# This script will identify all the words present in the language model
# not present in the supplied lexicon

"""
\data\
ngram  1=         6
ngram  2=         4
ngram  3=         3


\1-grams:
-0.90309	<s>	-0.0791812
-0.90309	The	-0.301031
-0.90309	dog	-0.301031
-0.90309	dies	-0.301031
-0.90309	</s>
-0.425969	<unk>

\2-grams:
-0.567298	<s> The	-0.301029
-0.249877	The dog	-0.301029
-0.249877	dog dies	-0.301029
-0.249877	dies </s>
"""

# sys.argv[1] = `ARPA`-style language model
# sys.argv[2] = boolean: language model is compressed (`.gz`)
# sys.argv[3] = current lexicon
# sys.argv[4] = lexicon delimiter (e.g. \t)
# sys.argv[5] = full path to output list of OOV words


lm = sys.argv[1]
compressed = ast.literal_eval(sys.argv[2])
lexicon = sys.argv[3]
lexicon_delimiter = sys.argv[4]

f_lex = open(lexicon, "r")

# build counter of lexicon words
cLex = Counter()
for line in f_lex:
    line_split = line.split(lexicon_delimiter)
    lex_id = line_split[0]
    cLex[lex_id] += 1
f_lex.close()

# build counter of oov words
cOOV = Counter()

if not compressed:
    f_lm = open(lm, "r")
else:
    f_lm = gzip.open(lm, "r")

flag = 0
for line in f_lm:
    if line == "" or line == "\n":
        flag = 0
    print(flag, line.rstrip())
    if flag == 1:
        # extract just the unigram
        line_split = line.rstrip().split("\t")
        token = line_split[1]
        # if unigram isn't a special token
        if not token.startswith("<"):
            if not cLex[token]:
                cOOV[token] += 1
    # set flag to capture only unigrams
    if line.startswith("\\1-grams:"):
        flag = 1

f_lm.close()

oov_list = list(cOOV.keys())
oov_list.sort()

f_out = open(sys.argv[5], "w")

for word in oov_list:
    f_out.write(word + "\n")

f_out.close()
