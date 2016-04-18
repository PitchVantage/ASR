#!/usr/bin/env python
#/usr/local/bin
#!/usr/bin/python
import re, locale
import sys

#Script: Format_Transcript_for_LM.py
#Author: Megan Willi
#Last Updated: 04_18_16

#Purpose: Reads in a transcript file with the audio file label and unformatted transcript. Outputs a .txt file with the audio file label removed and transcript in the correct format to create a language model from the .txt file.

#Command Line: ./Format_Transcript_for_LM.py [path/to/input/file] [path/to/output/file]

#Example Command Line: ./Format_Transcript_for_LM.py Train_transcripts.txt CLEAN_Train_transcripts_for_LM.txt

#Example Input File Format:
#44AC0207 The F\. S\. L\. I\. C\. fund is supposed to cover insured deposits of eight hundred ninety billion dollars in the nation\'s three thousand federally insured thrifts
#44AC0208 Even the Bank Board\'s stated one \.POINT nine billion dollars of reserves is the lowest ratio of reserves to deposits ever
#44AC0209 [tongue_click] Also pending are requests for more than two billion dollars in loans to troubled thrifts

#Example Output File Format:
#THE F. S. L. I. C. FUND IS SUPPOSED TO COVER INSURED DEPOSITS OF EIGHT HUNDRED NINETY BILLION DOLLARS IN THE NATION'S THREE THOUSAND FEDERALLY INSURED THRIFTS
#EVEN THE BANK BOARD'S STATED ONE .POINT NINE BILLION DOLLARS OF RESERVES IS THE LOWEST RATIO OF RESERVES TO DEPOSITS EVER
#ALSO PENDING ARE REQUESTS FOR MORE THAN TWO BILLION DOLLARS IN LOANS TO TROUBLED THRIFTS

#Command Line Variables:
#sys.ARGV[1]= Train_transcripts.txt
#sys.ARGV[2]= CLEAN_Train_transcripts_for_LM.txt

#Reads in input .txt transcript file.
f = open(sys.argv[1], "rb")

#Removes audio file label and conver transcript to all upper case.
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

#Convert transcript to a string.
ALL_final=str(ALL)
#print ALL_final

#Remove anything that isn't a number or a letter.
OUTPUT=re.sub(r'\[.*\]','',ALL_final)
OUTPUT2=re.sub(r'([^\s^\.^\'\w]|_)+','',OUTPUT)

#Write formatted transcript to an output .txt file.
with open(sys.argv[2], 'wb') as f:
    f.write(OUTPUT2)
f.close()

