#!/usr/bin/env bash

#!/bin/bash

# -p = number of processors to use
# -n = full path of training data    **In a location *OTHER THAN* inside egs/ folder
# -t = full path of testing data     **In a location *OTHER THAN* inside egs/ folder
# -a = full path of all all data     **In a location *OTHER THAN* inside egs/ folder
# -s = percentage of training split (e.g. .8)

# if needing split...
    #-a waves_dir
# if providing pre-split...
    #-n
    #-t
    #-s (optional)


# delete the three dirs generated by this script if they already exist
# so that we have a clean slate
#exp = monophones, lined monophones, and triphones
#along with any existing waves_dir, train_dir, and test_dir
rm -rf data/test_dir exp/make_mfcc/test_dir mfcc/cmvn_test* mfcc/raw_mfcc_test* waves_dir train_dir test_dir data/lang_test_tg exp_triphones_graph data/local/lm_tg.arpa

#default values for variables
numProcessors=1
sDefault=.8
#train_dir="train_dir"
test_dir="test_dir"
#waves_dir="waves_dir"

while getopts "p:n:t:a:s:e:m:d:i:" opt; do
    case $opt in
        p)
            numProcessors=$OPTARG        #update default setting
            ;;
        n)
            # make symbolic links from locations of true data to directories expected by kaldi
            n=$OPTARG
            ln -s $n train_dir
            ;;
        t)
            # make symbolic links from locations of true data to directories expected by kaldi
            t=$OPTARG
            ln -s $t test_dir
            ;;
        a)
            # make symbolic links from locations of true data to directories expected by kaldi
            a=$OPTARG
            ln -s $a waves_dir
            #make sure the audio files can be found
            if [ ! -d $waves_dir ]; then
                printf "\n####\n#### ERROR: audio files not found not found \n####\n\n";
                exit 1;
            fi
            ;;
        e)
            # make symbolic links from locations of true data to directories expected by kaldi
            e=$OPTARG
            ln -s $e exp
            ;;
        m)
            # make symbolic links from locations of true data to directories expected by kaldi
            m=$OPTARG
            ln -s $m mfcc
            ;;
        d)
            # make symbolic links from locations of true data to directories expected by kaldi
            d=$OPTARG
            ln -s $d data
            ;;
        i)
            # make symbolic links from locations of true data to directories expected by kaldi
            i=$OPTARG
            ln -s $i input
            ;;
        \?)
            echo "wrong parameters"
            exit 1
            ;;
    esac
done

mfcc_dir=mfcc

# These run.pl scripts take our commands, run them,
# parallelized if we want, and print out a log file.
#train_cmd="utils/run.pl"
decode_cmd="utils/run.pl"

printf "\n####======================================####\n";
printf "#### BEGIN DATA + LEXICON + LANGUAGE PREP ####\n";
printf "####======================================####\n\n";

#Print timestamp in HH:MM:SS (24 hour format)
printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"

#if [! -d test_waves_dir ]; then
#  printf "\n###\n### ERROR: ./test_waves_dir not found \n###\n\n";
#  exit1;
#fi

# sort input files by bytes (kaldi-style) and re-save them with orginal filename (re-writes it)
# Need all the files listed below.
# LC_ALL= this is setting your language context to be the C language
# All of these files are in the input folder
for fileName in lexicon.txt lexicon_nosil.txt phones.txt transcripts; do
    LC_ALL=C sort -i input/$fileName -o input/$fileName;
done;

# Given dir of WAV files, create dirs for train and test, create 'wav.scp',
# create 'text', create 'utt2spk' and 'spk2utt', and copy the language model
# from elsewhere (ARPA format)

#added fourth parameter to include split amount for training
#    # (used in create_waves_test_train.pl inside prepare data)
#local/prepare_data_generalized_all.sh $a $train_dir $test_dir $sDefault || \
#printf "\n####\n#### ERROR: prepare_data.sh \n####\n\n";



    #added fourth parameter to include split amount for training
    # (used in create_waves_test_train.pl inside prepare data)
local/prepare_data_test_only.sh $test_dir || \
printf "\n####\n#### ERROR: prepare_data.sh \n####\n\n";


local/prepare_lm.sh || printf "\n####\n#### ERROR: prepare_lm.sh\n####\n\n";



printf "\n####==========================####\n";
printf "#### BEGIN FEATURE EXTRACTION ####\n";
printf "####==========================####\n\n";

#Print timestamp in HH:MM:SS (24 hour format)
printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"

for dir in $test_dir; do

    steps/make_mfcc.sh --nj $numProcessors \
        data/$dir \
        exp/make_mfcc/$dir \
        $mfcc_dir \
        || printf "\n####\n#### ERROR: make_mfcc.sh \n####\n\n";

    steps/compute_cmvn_stats.sh \
        data/$dir \
        exp/make_mfcc/$dir \
        $mfcc_dir \
        || printf "\n####\n#### ERROR: compute_cmvn_stats.sh \n####\n\n";
done


printf "\n####=========================####\n";
printf "#### BEGIN GRAPH COMPILATION ####\n";
printf "####=========================####\n\n";

#Print timestamp in HH:MM:SS (24 hour format)
printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"

# Graph compilation

# This script creates a fully expanded decoding graph (HCLG) that represents
# the language-model, pronunciation dictionary (lexicon), context-dependency,
# and HMM structure in our model.  The output is a Finite State Transducer
# that has word-ids on the output, and pdf-ids on the input (these are indexes
# that resolve to Gaussian Mixture Models).

# utils/mkgraph.sh --mono \
#     data/lang_test_tg \
#     exp/mono \
#     exp/mono/graph_tgpr \
#     || printf "\n####\n#### ERROR: mkgraph.sh \n####\n\n";

utils/mkgraph.sh \
    data/lang_test_tg \
    exp/triphones \
    exp/triphones/graph \
    || printf "\n####\n#### ERROR: mkgraph.sh \n####\n\n";


printf "\n####===============####\n";
printf "#### BEGIN TESTING ####\n";
printf "####===============####\n\n";

#Print timestamp in HH:MM:SS (24 hour format)
printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"

# steps/decode.sh --nj $numProcessors --cmd "$decode_cmd" \
#     exp/mono/graph_tgpr \
#     data/$test_dir \
#     "exp/mono/decode_$test_dir" \
#     || printf "\n####\n#### ERROR: decode.sh \n####\n\n";

steps/decode.sh --nj $numProcessors --cmd "$decode_cmd" \
    exp/triphones/graph \
    data/$test_dir \
    "exp/triphones/decode_$test_dir" \
    || printf "\n####\n#### ERROR: decode.sh \n####\n\n";



printf "\n####=====================####\n";
printf "#### BEGIN CALCULATE WER ####\n";
printf "####=====================####\n\n";

#Print timestamp in HH:MM:SS (24 hour format)
printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"

for x in exp/*/decode*; do
    [ -d $x ] && grep WER $x/wer_* | utils/best_wer.sh;
done

rm -rf waves_dir
rm -rf test_dir
rm -rf train_dir
rm -rf exp
rm -rf mfcc
rm -rf data
rm -rf input


printf "\n####=========####\n";
printf "#### Finished ####\n";
printf "####===========####\n\n";

#Print timestamp in HH:MM:SS (24 hour format)
printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"
