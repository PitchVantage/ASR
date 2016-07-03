#!/bin/bash

#Script: Create_lm.sh
#Author: Megan Willi
#Last Updated: 04_18_16

#Purpose:Read in clean, formatted, uppercase lm transcript. Output language model created from the lm transcript.  Does *not* take sentence-ends into consideration.
#Command Line: ./Create_lm.sh [path/to/input/CLEAN_transcripts/file] [path/to/output/lm.arpabo/file]

#Example Command Line: ./Create_lm.sh CLEAN_transcript.txt Output_lm.arpabo

#Command Line Variables:
#$1= CLEAN_transcript.txt
#$2= Output_lm.arpabo

input=$1
output=$2

export IRSTLM=/data/Github/ASR/tools/extras/irstlm
export PATH=${PATH}:${IRSTLM}/bin


build-lm.sh -i $1 -n 3 -o train.ilm.gz -k 5

compile-lm --text=yes train.ilm.gz $output

rm train.ilm.gz
