#!/usr/bin/env bash


test_list=$1
all_transcripts=$2
output=$3

while read utterance
do
    grep -F $utterance $all_transcripts | uniq >> $output

done < $test_list

