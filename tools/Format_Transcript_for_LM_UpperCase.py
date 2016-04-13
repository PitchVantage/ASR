#!/usr/bin/env python
#/usr/local/bin
#!/usr/bin/python
import re, locale

print "Hello World!"

f = open("LM_transcripts_upper_case.txt", "rb")

ALL=""
sentence=[]
for line in f:
   line_split = line.split(" ")
   id = line_split[0]
   sentence_tokens = line_split[1:]
   sentence = " ".join(sentence_tokens)
   sentence=str(sentence)
   sentence=sentence.upper()
   sentence=sentence.strip() + "\n"
   ALL= ALL + sentence
    
ALL_final=str(ALL)
#print ALL_final

#Remove anything that isn't a number or a letter:
OUTPUT=re.sub(r'\[.*\]','',ALL_final)
OUTPUT2=re.sub(r'([^\s^\.^\'\w]|_)+','',OUTPUT)

with open('CLEAN_LM_transcripts_upper_case2.txt', 'wb') as f:
    f.write(OUTPUT2)
f.close()

