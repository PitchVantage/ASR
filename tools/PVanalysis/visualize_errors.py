import re
import sys
from nltk.corpus import wordnet
import math

# Given a gold transcript file and a `best path` file from `kaldi`, this script will
# generate an `html` output color-coding the errors made by the prediction

# created by Mohsen Mahdavi (mahdavi@email.arizona.edu)

# sys.argv[1] = full path to gold `transcript` file 
# sys.argv[2] = full path to `best path` file (`exp/triphones/decode_test_dir/scoring/log/best_path.9.log`)
# sys.argv[3] = full path to output `html` file

gold = sys.argv[1]
guess = sys.argv[2]
html = sys.argv[3]

counter = 0
guessLines = []
goldLines = []
allGoldWords = {}
seenLOG = False

def howSignificant(word):
    syn = wordnet.synsets(word)
    result = 0
    if len(syn)<1:
        result += 4
    result += len(word)/2
    repetitions = allGoldWords[word]
    result -= math.sqrt(repetitions)
    result += 5
    return result
#################################################################################

with open(guess) as f:
    for line in f:
        if line[:3] != 'LOG' and seenLOG and line[0]!='#' and len(line.strip())>10:
            line = re.sub('\d[^ ]* ','',line)
            line = re.sub('(XYZ )+','XYZ ',line)
            guessLines.append(line)
            counter+=1
        elif line[:3] == 'LOG':
            seenLOG = True
            
with open(gold) as f:
    for line in f:
        line = re.sub('\d[^ ]* ','',line)
        line = re.sub('(XYZ )+','XYZ ',line)
        goldLines.append(line)
        for word in line.split():
                if word in allGoldWords:
                    allGoldWords[word] += 1
                else:
                    allGoldWords[word] = 1
    
result = "<html><head><title>Transcription evaluation</title></head><body style='margin: 40px;'>"

xyzcounter = 0
errorWordCounter = 0
#Now compare the two texts:        
for i in range(counter):
    #print(guessLines[i])
    #print(goldLines[i])
    guess = guessLines[i].split()
    gold = goldLines[i].split()
    correct = []
    lastCorrectIndex = -1
    printMode = False
    for j in range(len(guess)):
        word = guess[j]
        if word=='XYZ':
            xyzcounter += 1;
        for k in range(lastCorrectIndex+1,lastCorrectIndex+100):
            if k<len(gold):
                candidate = gold[k]
                ###
#                 if 'TRIGGERS' == word:
#                     printMode  = True
#                 if 'MATURE' == word:
#                     printMode  = False    
#                 if printMode==True and word=='FLOWER':
#                     print(word+', '+candidate)
                 ###
                normalizedDistance = (k-lastCorrectIndex)/2
                if word=='NONDESCRIPT':
                    print(word+', '+candidate+': '+str(howSignificant(word))+', '+str(normalizedDistance))
                if (candidate == word) and (k-lastCorrectIndex<2 or 
                                             (normalizedDistance < howSignificant(word)) or
                                             (len(guess)>j+1 and len(gold)>k+1 and guess[j+1]==gold[k+1] and howSignificant(word)+howSignificant(guess[j+1])>5) or
                                             (len(guess)>j+2 and len(gold)>k+2 and guess[j+1]==gold[k+1] and guess[j+2]==gold[k+2])):
                    if printMode==True and word=='NONDESCRIPT':
                        print('found: '+candidate+', '+word+'\t'+str(howSignificant(word))+', '+str(normalizedDistance))
                    if candidate=='XYX' and k-lastCorrectIndex>1:
                        continue
                    correct.append(k)
                    lastCorrectIndex = k
                    break
        else:
            correct.append(-1)
    #Now print the diff:
    j = 0
    lastPrintedGold = -1
    result += "<p style='margin-bottom: 10px;'>"
    #For each word in the line in the guessed transcript:
    numberOfErrors = 0
    while j<len(guess):
        #If this word had a match in the gold transcript:
        if correct[j] != -1:
            if correct[j]-lastPrintedGold>1:
                #Print the non-printed gold words first
                for iter in range(lastPrintedGold+1,correct[j]):
                    result += "<span style='color: blue'>("+gold[iter]+")</span> " 
            result += guess[j]+" "
            lastPrintedGold = correct[j]
        #If it was a wrong guess and has to be shown in red:
        else:
            tempResult = ''
            while j<len(guess) and correct[j]==-1:
                tempResult += guess[j]+" "
                j += 1
            j -= 1
            if len(tempResult)>0:
                numberOfErrors += 1
            result += "<span style='color: red'>"+tempResult+" </span>"
        j += 1   
    result += "</p>\n"
    errorWordCounter += numberOfErrors;
    if numberOfErrors>0:
        print(str(len(guess))+': line had errors:'+str(numberOfErrors))
    else:
        print(str(len(guess))+': ok')
result += "</body></html>"
    
    
shortFile = open(html, 'w')
shortFile.write(result)
shortFile.close()

print(str(xyzcounter)+' XYZ in '+str(errorWordCounter)+" errors")



    
