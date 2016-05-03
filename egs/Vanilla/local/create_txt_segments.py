#!/usr/bin/env python
#/usr/local/bin
#!/usr/bin/python
import re, locale
import sys

#Script: create_txt_segments.py
#Author: Megan Willi
#Last Updated: 04_28_16

#Purpose: Reads in a transcript file and a list of .wav filenames. Looks up the transcripts that relate to the list of .wav filenames. Outputs a transcript files with only transcripts relevant to the list of .wav filenames.

#Command Line: ./create_txt_segments.py [path/to/transcript/file] [path/to/list_of_waves/file]

#Example Command Line: ./create_txt_segments.py /Volumes/poo/ASR/egs/Input_Folders/input_V3/TED_Segment_XYZ_transcript.txt /Volumes/poo/ASR/egs/Vanilla_TED_mini/data/local/waves.train

#Command Line Variables:
#sys.argv[1]= Train_transcripts.txt
#sys.argv[2]= waves.train


#Reads in input waves.train file.
f2 = open(sys.argv[2], "rb")

#Creates output transcript file with only transcripts from wave.train file list.
#f3 = open(sys.argv[3], "wb")

for wav in f2:
    id=wav.split(".")[0]
    #Reads in input .txt transcript file.
    f = open(sys.argv[1], "rb")
    for line in f:
        if id in line.split(" ")[0]:
            print line.rstrip()
    f.close()
#f3.close()
f2.close()


