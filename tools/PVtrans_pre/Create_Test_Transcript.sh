#!/usr/bin/env bash

#Script: Create_Test_Transcripts.sh
#Author: Megan Willi
#Last Updated: 04_18_16

#Purpose: Reads in a transcript file with the audio file label and a list of audio file labels to be included as the test set. Outputs a .txt file with the audio file label and transcripts for the test set.

#Command Line: ./Create_Test_Transcripts.sh [path/to/list/of/test/audio/labels] [path/to/transcript/file][path/to/output/test/transcript/file]

#Example Command Line: ./Create_Test_Transcripts.sh test_list.txt transcripts.txt output_transcripts.txt

#Command Line Variables:
#$1= test_list.txt
#$2= transcripts.txt
#$3= output_test_transcripts.txt

test_list=$1
all_transcripts=$2
output=$3

while read utterance
do
    grep -F $utterance $all_transcripts | uniq >> $output

done < $test_list

