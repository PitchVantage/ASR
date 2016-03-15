#!/bin/bash

# make both model/data/ and model/data/local/
mkdir -p data/local

echo "Preparing train and test data"

waves_dir=$1
train_dir=$2
test_dir=$3
split=$4

cd data/local

#if $train_dir == "train_dir" then no training split exists yet
if [ $train_dir == "train_dir" ]; then

    # print all the filenames from the model/waves_dir to the text file:
    # model/data/local/waves_all.list
#    ls -1 ../../$waves_dir > waves_all.list
    ls -1 $waves_dir > waves_all.list

    #run create_waves_test_train.pl
    # split the complete list of wave files from waves_all.list into a train and
    # test set, and print two new text files of the filenames for test and training
    ../../local/create_waves_test_train.pl waves_all.list waves.test waves.train $split

    # sort files by bytes (kaldi-style) and re-save them with orginal filename
    for fileName in waves_all.list waves.test waves.train; do
        LC_ALL=C sort -i $fileName -o $fileName;
    done;

       # make a two-column list of test utterance ids and their paths
    ../../local/create_wav_scp.pl ${waves_dir} waves.test > \
        ${test_dir}_wav.scp

    # make a two-column list of train utterance ids and their paths
    ../../local/create_wav_scp.pl ${waves_dir} waves.train > \
        ${train_dir}_wav.scp

    # need to make these two files of transcriptions:
    # <utterance-id> <text>
    ../../local/create_txt.pl ../../input/transcripts waves.train > ${train_dir}.txt
    ../../local/create_txt.pl ../../input/transcripts waves.test > ${test_dir}.txt

    cp ../../input/task.arpabo lm_tg.arpa

    cd ../..

    for x in $train_dir $test_dir; do
        mkdir -p data/$x
        cp data/local/${x}_wav.scp data/$x/wav.scp
        cp data/local/$x.txt data/$x/text
        cat data/$x/text | awk '{printf("%s %s\n", $1, $1);}' > data/$x/utt2spk
        utils/utt2spk_to_spk2utt.pl <data/$x/utt2spk >data/$x/spk2utt
    done

#train and test data already provided
else

    #write waves.test and waves.train
    ls -1 $train_dir > waves.train
    ls -1 $test_dir > waves.test

    # sort files by bytes (kaldi-style) and re-save them with orginal filename
    for fileName in waves.test waves.train; do
        LC_ALL=C sort -i $fileName -o $fileName;
    done;

    # make a two-column list of test utterance ids and their paths
        #feed the test directory
    ../../local/create_wav_scp.pl ${test_dir} waves.test > \
        ${test_dir}_wav.scp

    # make a two-column list of train utterance ids and their paths
        #feed the train directory
    ../../local/create_wav_scp.pl ${train_dir} waves.train > \
        ${train_dir}_wav.scp


    # need to make these two files of transcriptions:
    # <utterance-id> <text>
    ../../local/create_txt.pl ../../input/transcripts waves.train > ${train_dir}.txt
    ../../local/create_txt.pl ../../input/transcripts waves.test > ${test_dir}.txt

    cp ../../input/task.arpabo lm_tg.arpa

    cd ../..

    #TODO ==============================================

    for x in $train_dir $test_dir; do
        mkdir -p data/$x
        cp data/local/${x}_wav.scp data/$x/wav.scp
        cp data/local/$x.txt data/$x/text
        cat data/$x/text | awk '{printf("%s %s\n", $1, $1);}' > data/$x/utt2spk
        utils/utt2spk_to_spk2utt.pl <data/$x/utt2spk >data/$x/spk2utt
    done

fi






