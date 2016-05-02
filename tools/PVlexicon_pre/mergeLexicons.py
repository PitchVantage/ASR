import sys
import re

#merges two lexicons together
#NOTE:  They **must both** be sorted alphabetically already!

#sys.argv[1] = full path to location for merged output lexicon
#sys.argv[2] = lexicon one
#sys.argv[3] = lexicon two

#open file for outputing new lexicon
fOut = open(sys.argv[1], "wb")


#convert lex_1 to tuple_list 
lex_1 = []
f = open(sys.argv[2], "rb")
for line in f:
    #split on whitespace
    if "\t" in line:
        split = line.rstrip().split("\t")
    else:
        split = line.rstrip().split(" ")
    #capture word and transcription
    word = split[0]
    trans = split[1:]
    #add to dictionary
    lex_1.append((word, trans))
f.close()

#convert lex_2 to tuple_list
lex_2 = []
f = open(sys.argv[3], "rb")
for line in f:
    #split on whitespace
    if "\t" in line:
        split = line.rstrip().split("\t")
    else:
        split = line.rstrip().split(" ")
    #capture word and transcription
    word = split[0]
    trans = split[1:]
    #add to dictionary
    lex_2.append((word, trans))
f.close()
    
#mark longest lexicon as lex_master
if len(lex_1) >= len(lex_2):
    lex_master = lex_1
    lex_minor = lex_2
else:
    lex_master = lex_2
    lex_minor = lex_1

#multiple pronunciation regex
reg = r'(.+)\((\d+)\)'

#set counters
l1 = 0
l2 = 0

print("master", range(len(lex_master)))
print("minor", range(len(lex_minor)))

#use longer lexicon for iteration
while l1 in range(len(lex_master)) and l2 in range(len(lex_minor)):
# for i in range(len(lex_master)):
    print("l1", l1)
    print("l2", l2)
    print("current master", lex_master[l1][0], lex_master[l1][1])
    print("current minor", lex_minor[l2][0], lex_minor[l2][1])
    # if l1 in range(len(lex_master)) and l2 in range(len(lex_minor)):
    print("both lists active")
    #current lex_master word
    word_master = lex_master[l1][0]
    #current lex_master transcription
    trans_master = lex_master[l1][1]
    #current phonetic key
    key_master = 1
    #extract multiple pronunciation key if present
    if re.match(reg, word_master):
        match = re.match(reg, word_master)
        word_master = match.group(1)
        key_master = int(match.group(2))
    #current lex_minor word
    word_minor = lex_minor[l2][0]
    #current lex_minor transcription
    trans_minor = lex_minor[l2][1]
    #current phonetic key
    key_minor = 1
    #extract multiple pronunciation key if present
    if re.match(reg, word_minor):
        match = re.match(reg, word_minor)
        word_minor = match.group(1)
        key_minor = int(match.group(2))
    #conditions
    #if exact same word, add only once
    if word_master == word_minor and trans_master == trans_minor:
        print("adding word from master", word_master)
        #write to file
        if key_master == 1:
            fOut.write(word_master + " " + " ".join(trans_master) + "\n")
        else:
            fOut.write(word_master + "(" + str(key_master) + ") " + " ".join(trans_master) + "\n")
        #update both counters
        l1 += 1
        l2 += 1
    elif word_master == word_minor and trans_master != trans_minor:
        print("adding word from master", word_master)
        if key_master == 1:
            fOut.write(word_master + " " + " ".join(trans_master) + "\n")
        else:
            fOut.write(word_master + "(" + str(key_master) + ") " + " ".join(trans_master) + "\n")
        print("adding word from minor with additional pronunciation", word_minor)
        fOut.write(word_minor + "(" + str(key_master + 1) + ") " + " ".join(trans_minor) + "\n")
        l1 += 1
        l2 += 1
    else:
        #if word_master comes before word minor, add word_master
        if word_master < word_minor:
            print("adding word from master", word_master)
            #write to file
            if key_master == 1:
                fOut.write(word_master + " " + " ".join(trans_master) + "\n")
            else:
                fOut.write(word_master + "(" + str(key_master) + ") " + " ".join(trans_master) + "\n")
            #update master counter
            l1 += 1
    #if word_minor comes before word_master, add word_minor
        elif word_master > word_minor:
            print("adding word from minor", word_minor)
            #write to file
            if key_minor == 1:
                fOut.write(word_minor + " " + " ".join(trans_minor) + "\n")
            else:
                fOut.write(word_minor + "(" + str(key_minor) + ") " + " ".join(trans_minor) + "\n")
            #update minor counter
            l2 += 1
        else:
            l1 += 1
            l2 += 1
while l1 in range(len(lex_master)):
    # elif l1 in range(len(lex_master)):
    print("master only active")
    #current lex_master word
    word_master = lex_master[l1][0]
    #current lex_master transcription
    trans_master = lex_master[l1][1]
    #current phonetic key
    key_master = 1
    #extract multiple pronunciation key if present
    if re.match(reg, word_master):
        match = re.match(reg, word_master)
        word_master = match.group(1)
        key_master = int(match.group(2))
    print("adding word from master", word_master)
    #write to file
    if key_master == 1:
        fOut.write(word_master + " " + " ".join(trans_master) + "\n")
    else:
        fOut.write(word_master + "(" + str(key_master) + ") " + " ".join(trans_master) + "\n")
    #update master counter
    l1 += 1

fOut.close()









