#!/usr/bin/env bash

#!/bin/bash

# make both model/data/ and model/data/local/
#mkdir -p data/local

echo "Preparing test data"

test_dir=$1

#Appears to be a problem with my relative location. Need to figure out how to establish where I am in this bash script.

#write waves.test
ls -1 $test_dir > data/local/waves.test

# sort files by bytes (kaldi-style) and re-save them with orginal filename
for fileName in data/local/waves.test; do
    LC_ALL=C sort -i $fileName -o $fileName;
done;


# make a two-column list of test utterance ids and their paths
    #feed the test directory
local/create_wav_scp.pl ${test_dir} data/local/waves.test > \
    data/local/${test_dir}_wav.scp
local/create_wav_scp.pl ${test_dir} data/local/waves.test > \
data/local/${test_dir}_wav.scp

# need to make these two files of transcriptions:
# <utterance-id> <text>
local/create_txt.pl input/transcripts data/local/waves.test > data/local/${test_dir}.txt

cp input/task.arpabo data/local/lm_tg.arpa

for x in $test_dir; do
    mkdir -p data/$x
    cp data/local/${x}_wav.scp data/$x/wav.scp
    cp data/local/$x.txt data/$x/text
    cat data/$x/text | awk '{printf("%s %s\n", $1, $1);}' > data/$x/utt2spk
    utils/utt2spk_to_spk2utt.pl <data/$x/utt2spk >data/$x/spk2utt
done


