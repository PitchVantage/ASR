import sys
from collections import Counter
import re
import os

#method to estimate how many named entities an ASR output got correct

#sys.argv[1] = transcript file
#sys.argv[2] = location of ASR transcripts

#########number of named entities in gold transcripts##################

#counters to hold tokens
ne = Counter()
non_ne = Counter()

f = open(sys.argv[1], "rb")

id_regex = r'^[0-9A-z]+.*'

backslash_regex = r'\\'

for line in f:
    line_split = line.rstrip().split(" ")
    #if first item is utterance ID
    if re.match(id_regex, line):
        sentence = line_split[1:]
    #if there is no utterance ID
    else:
        sentence = line_split
    #for each idx in sentence
    for i in range(len(sentence)):
            word = sentence[i]
            #remove any backslashes
            clean_word = re.sub(backslash_regex, "", word)
            #if it's not first word in sentence and is capitalized
            if i != 0 and clean_word[0].isupper():
                ne[clean_word.lower()] += 1
            else:
                non_ne[clean_word.lower()] += 1

ne_count = sum(ne.values())
non_ne_count = sum(non_ne.values())
total_count = ne_count + non_ne_count

ne_rate = float(ne_count) / float(total_count)

print("number of named entities", ne_count)
print("number of non named entities", non_ne_count)
print("percentage of named entities", ne_rate)

f.close()

##########named entity rate in ASR transcripts#################

#coarse comparison: see how many of the named entities in `ne` appear
#in the ASR transcripts

#path
transcript_path = sys.argv[2]

#all files in directory (not including path)
all_ASR_transcripts = os.listdir(transcript_path)
#all files - including path
all_ASR_transcripts_fullPath = [transcript_path + "/" + all_ASR_transcripts[i] for i in range(len(all_ASR_transcripts))]

#concatenate all transcripts into one list of words
all_words = Counter()

for asr_file in all_ASR_transcripts_fullPath:
    f = open(asr_file, "rb")
    for line in f:
        line_split = line.split(" ")
        if re.match(id_regex, line):
            sentence = line_split[1:]
        #if there is no utterance ID
        else:
            sentence = line_split
        #add each word to all_words counter
        for token in sentence:
            all_words[token.lower()] += 1
    f.close()

#all_words counter - non_ne = all_words ne
    #this is an approximation of the words that the ASR system assigned to named entities
all_words_ne = all_words - non_ne

print("approximate named entities as transcribed by ASR", all_words_ne)

#real ne - approximate ne = incorrect ne
    #this is an approximation of the named entities that the ASR system got incorrect
incorrect_ne = ne - all_words_ne

print("incorrect named entities as transcribed by ASR", incorrect_ne)

#count of incorrect_ne
incorrect_ne_count = sum(incorrect_ne.values())

#percentage of incorect ne to entire number of words
incorrect_ne_rate = float(incorrect_ne_count) / float(total_count)

print("percentage of incorrect named entities", incorrect_ne_rate)


correct = 0
incorrect = 0
total = 0

for word in ne.keys():
    total += 1
    if word in all_words:
        correct += 1
    else:
        incorrect += 1

incorrect_ne_rate_distinct = float(incorrect) / float(total)

print("percentage of distinct incorrect named entities", incorrect_ne_rate_distinct)

