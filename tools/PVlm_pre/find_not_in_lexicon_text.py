import sys
from collections import Counter

# This script will identify all the words present in the files used to build
# the language model that are not present in the supplied lexicon

# sys.argv[1] = list of files used to build language model
# sys.argv[2] = current lexicon
# sys.argv[3] = lexicon delimiter (e.g. \t)
# sys.argv[4] = full path to output list of OOV words

lm_file_paths = sys.argv[1].split(" ")
lexicon = sys.argv[2]
lexicon_delimiter = sys.argv[3]

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

for file_path in lm_file_paths:
    f = open(file_path, "r")
    for line in f:
        # tokenize
        line_split = line.rstrip().split(" ")
        for token in line_split:
            # if not in lexicon
            if not cLex[token]:
                cOOV[token] += 1
    f.close()

oov_list = list(cOOV.keys())
oov_list.sort()

f_out = open(sys.argv[4], "w")

for word in oov_list:
    f_out.write(word + "\n")

f_out.close()
