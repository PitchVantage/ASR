import sys
from collections import Counter

# This script will ensure all phones present in `lexicon` are in `phones` list.
# Outputs a `phones` list guaranteed to have all phones from lexicon

# sys.argv[1] = full path to existing `lexicon`
# sys.argv[2] = full path to existing `phones`
# sys.argv[3] = full path for updated `phones`

# open file for current phones
f_phones = open(sys.argv[2], "r")

# build counter of all phones in phones
c_phones = Counter()

for line in f_phones:
    c_phones[line.rstrip()] += 1

f_phones.close()

# open file for current lexicon
f_lex = open(sys.argv[1], "r")

# iterate through lexicon
for line in f_lex:
    # split on whitespace
    if "\t" in line:
        split = line.rstrip().split("\t")
        # capture word and transcription
        word = split[0]
        trans = split[1].split(" ")
    else:
        split = line.rstrip().split(" ")
        # capture word and transcription
        word = split[0]
        trans = split[1:]
    for phone in trans:
        if phone not in c_phones:
            c_phones[phone] += 1
            print("adding " + phone)

f_lex.close()

# sort Counter
phones_list = list(c_phones.keys())
phones_list.sort()

f_out = open(sys.argv[3], "w")

for phone in phones_list:
    f_out.write(phone + "\n")

f_out.close()

