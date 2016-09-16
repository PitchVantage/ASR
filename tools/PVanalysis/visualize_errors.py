import re
import sys

# Given a gold transcript file and a `best path` file from `kaldi`, this script will
# generate an `html` output color-coding the errors made by the prediction

# created by Mohsen Mahdavi (mahdavi@email.arizona.edu)

# sys.argv[1] = full path to gold `transcript` file 
# sys.argv[2] = full path to `best path` file (`exp/triphones/decode_test_dir/scoring/log/best_path.9.log`)
# sys.argv[3] = full path to output `html` file

try:
    goldAddr = sys.argv[1]
    guessAddr = sys.argv[2]
    destAddr = sys.argv[3]
except:
    print("GOT: "+str(sys.argv))
    print("USAGE: arg1=goldTranscript, arg2=guessTranscript, arg3=destination")
    sys.exit()


seenLOG = False

#Read the two files
guessWords = []
goldWords = []
lineCounter = 0
with open(guessAddr) as f:
    for line in f:
        lineCounter += 1
        if True:#line[:3] != 'LOG' and seenLOG and line[0]!='#' and len(line.strip())>10:
            line = re.sub('\d[^ ]* ','',line)
            line = re.sub('-','',line)
            line = re.sub('^\\w+_\\w+ ','',line)
            line = re.sub('(XYZ )+','XYZ ',line)
            if line[:10]=='LOG (latti':
                continue
            line = re.sub('^.*\\_\\d+ ','',line)
            for word in line.split():
                word = re.sub('.*_','',word)
                guessWords.append(word.upper())
        elif line[:3] == 'LOG':
            seenLOG = True           
#         if lineCounter%50==0:
#             print(lineCounter)
with open(goldAddr) as f:
    for line in f:
        line = re.sub('\d[^ ]* ','',line)
        line = re.sub('(XYZ )+','XYZ ',line)
        for word in line.split():
            word = re.sub('.*_','',word)
            goldWords.append(word)
    
print('finished reading')
print('size: '+str(len(goldWords)))
print('size: '+str(len(guessWords)))
#Create Dynamic programming table
dpTable = []
path = []
for i in range(len(goldWords)+1):
    row = []
    pathRow = []
    for j in range(len(guessWords)+1):
        pathRow.append(0)
        if i==0:
            row.append(j)
        elif j==0:
            row.append(i)
        else:
            row.append(10000)
    dpTable.append(row)
    path.append(pathRow)

print('start the main loop')

#The main DP loop    
for i in range(1,len(goldWords)+1):
    for j in range(1,len(guessWords)+1):
#         if j%100==0 and i%100==0:
#             print(str(i)+", "+str(j))
        if (abs(i-j)>600):
            continue
        go = goldWords[i-1]
        gue = guessWords[j-1]
#         if i==j and i<110 and i>100:
#             print(go+' '+gue)
        if go==gue:
            substitutionCost = 0
        else:
            substitutionCost = 1
        toCompare = [dpTable[i-1][j]+1, dpTable[i][j-1]+1, dpTable[i-1][j-1]+substitutionCost]  #deletion, insertion, substitution
        dpTable[i][j] = min(toCompare)
        path[i][j] = toCompare.index(min(toCompare))+1
wer = 100*((0.1+dpTable[len(goldWords)][len(guessWords)])/len(goldWords))
wer = "%.2f" % wer
print('WER: '+str(dpTable[len(goldWords)][len(guessWords)])+' of '+str(len(goldWords)))
print('('+wer+'%)')

###Debugging the DP  table
# toPrint = ''
# for i in range(0,len(goldWords),100):
#     for j in range(0,len(guessWords),100):
#         toPrint += str(dpTable[i][j])+'\t'
#     toPrint += '\n'
#      
# print(toPrint)


#Print colorful
result = "</body></html>"
i = len(goldWords)
j = len(guessWords)
while j>0 and i>0:
#     print(str(i)+' '+str(j))
    if path[i][j]==3:    #substitution
        if goldWords[i-1]==guessWords[j-1]:
            result = goldWords[i-1]+' '+result
        else:
            result = "<span style='color: red'>"+guessWords[j-1]+"</span> "+"<span style='color: blue'>("+goldWords[i-1]+")</span> "+result
        i = i-1
        j = j-1
    if path[i][j]==2:    #insertion
        result = "<span style='color: red'>"+guessWords[j-1]+"</span> "+result
        j = j-1
    if path[i][j]==1:    #deletion
        result = "<span style='color: blue'>("+goldWords[i-1]+")</span> "+result
        i = i-1

result = '<br>WER: '+str(dpTable[len(goldWords)][len(guessWords)])+' of '+str(len(goldWords)) +' ('+wer+'%)<br>'+ result
result = "<html><head><title>Transcription evaluation</title></head><body style='margin: 40px;'> "+result

shortFile = open(destAddr, 'w')
shortFile.write(result)
shortFile.close()
