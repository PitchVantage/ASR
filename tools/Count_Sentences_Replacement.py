#!/usr/bin/env python
#/usr/local/bin
#!/usr/bin/python


#Michael Edit:
import re, locale

print "Hello World!"

f = open("lexicon.txt", "rb")

Words=[]
for line in f:
   line_split = line.split("\t")
   id = line_split[0]
   Words.append(id)
f.close

f = open("LM_Train_transcripts_upper_case.txt", "rb")
f3= open("Clean_LM_Train_transcripts_upper_case.txt", "wb")
for line in f:
    NEW_line=[]
    line_split = line.rstrip().split(" ")
    for token in line_split:
        if token not in Words:
            NEW_line.append("XYZ")
        else:
            NEW_line.append(token)
    Sentence=" ".join(NEW_line)
    f3.write(Sentence+"\n")
f.close
f3.close



