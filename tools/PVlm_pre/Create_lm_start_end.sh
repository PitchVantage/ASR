#!/bin/bash

#Script: Create_lm_start_end.sh
#Author: Megan Willi
#Last Updated: 04_18_16

#Purpose: Read in clean, formatted, uppercase lm transcript. Output language model created from the lm transcript with start (i.e. <s>) and end (i.e. </s>) markers included.
#Command Line: ./Create_lm_start_end.sh [path/to/input/CLEAN_transcripts/file] [path/to/output/lm.arpabo/file]

#Example Command Line: ./Create_lm_start_end.sh CLEAN_transcript.txt Output_lm.arpabo
#Example Command Line: ./Create_lm_start_end.sh CLEAN_transcript.txt Output_lm.arpabo

#Command Line Variables:
#$1= CLEAN_transcript.txt
#$2= Output_lm.arpabo

input=$1
output=$2

export IRSTLM=/Volumes/poo/ASR/tools/extras/irstlm
export PATH=${PATH}:${IRSTLM}/bin

add-start-end.sh < $1 >> output.txt

new_input=output.txt

build-lm.sh -i $new_input -n 3 -o train.ilm.gz -k 5

compile-lm --text=yes train.ilm.gz $output

rm train.ilm.gz
