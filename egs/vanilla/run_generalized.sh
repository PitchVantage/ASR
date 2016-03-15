#!/usr/bin/env bash

#!/bin/bash

# if needing split...
    #-a waves_dir
    #-s (optional)
# if providing pre-split...
    #-n
    #-t
# -p = number of processors to use
# -n = location of training data    **Name something other than "train_dir"
# -t = location of testing data     *Name something other than "test_dir"
# -a = location of all all data
# -s = percentage of training split (e.g. .8)

#default values for variables
numProcessors=1
sDefault=.8
train_dir="train_dir"
test_dir="test_dir"
waves_dir="NA"

while getopts "p:n:t:a:s:" opt; do
    case $opt in
        p)
            numProcessors=$OPTARG        #update default setting
            ;;
        n)
            train_dir=$OPTARG
            ;;
        t)
            test_dir=$OPTARG
            ;;
        a)
            waves_dir=$OPTARG
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
train_cmd="utils/run.pl"
decode_cmd="utils/run.pl"

printf "\n####======================================####\n";
printf "#### BEGIN DATA + LEXICON + LANGUAGE PREP ####\n";
printf "####======================================####\n\n";

# delete the three dirs generated by this script if they already exist
# so that we have a clean slate
#exp = monophones, lined monophones, and triphones
#These are the only 3 folder that this script writes to, but it reads from other places.
rm -rf data exp mfcc

# Make sure we have the data if -a flag used
#waves_dir = where the audio goes
if [ ! $waves_dir == "NA" ]; then
    if [ ! -d $waves_dir ]; then
        printf "\n####\n#### ERROR: audio files not found not found \n####\n\n";
        exit 1;
    fi
fi

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
# (used in create_waves_test_train.pl inside prepare data)
local/prepare_data.sh $waves_dir $train_dir $test_dir $sDefault || \
    printf "\n####\n#### ERROR: prepare_data.sh \n####\n\n";

# Copy and paste existing phonetic dictionary, language model, and phone list

local/prepare_dict.sh || printf "\n####\n#### ERROR: prepare_dict.sh\n####\n\n";

# Prepare (1) a directory such as data/lang/ (2) silence_phones.txt,
# (3) nonsilence_phones.txt (4) optional_silence.txt and (5) extra_questions.txt
# This script adds word-position-dependent phones and constructs a host of other
# derived files, that go in data/lang/.

utils/prepare_lang.sh --position-dependent-phones false \
    data/local/dict \
    "<unk>" \
    data/local/lang \
    data/lang \
    || printf "\n####\n#### ERROR: prepare_lang.sh\n####\n\n";

local/prepare_lm.sh || printf "\n####\n#### ERROR: prepare_lm.sh\n####\n\n";



printf "\n####==========================####\n";
printf "#### BEGIN FEATURE EXTRACTION ####\n";
printf "####==========================####\n\n";

for dir in $train_dir $test_dir; do

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



printf "\n####===========================####\n";
printf "#### BEGIN TRAINING MONOPHONES ####\n";
printf "####===========================####\n\n";

# Flat start and monophone training, with delta-delta features.
# This script applies cepstral mean normalization (per speaker).

steps/train_mono.sh --nj $numProcessors \
    --cmd "$train_cmd" --totgauss 400 \
    data/$train_dir \
    data/lang \
    exp/monophones \
    || printf "\n####\n#### ERROR: train_mono.sh \n####\n\n";


printf "\n####========================####\n";
printf "#### BEGIN ALIGN MONOPHONES ####\n";
printf "####========================####\n\n";

# Align monophones with data.

# Computes training alignments using a model with delta or
# LDA+MLLT features.

steps/align_si.sh --cmd "$train_cmd" --nj $numProcessors --boost-silence 1.25 \
    data/$train_dir \
    data/lang \
    exp/monophones \
    exp/monophones_aligned \
    || printf "\n####\n#### ERROR: align_si.sh \n####\n\n";


printf "\n####==========================####\n";
printf "#### BEGIN TRAINING TRIPHONES ####\n";
printf "####==========================####\n\n";

# Train tri1, which is deltas + delta-deltas, on train data.

numLeavesTriphones=2000
numGaussTriphones=10000

steps/train_deltas.sh --cmd "$train_cmd" \
    $numLeavesTriphones \
    $numGaussTriphones \
    data/$train_dir \
    data/lang \
    exp/monophones_aligned \
    exp/triphones \
    || printf "\n####\n#### ERROR: train_deltas.sh \n####\n\n";



printf "\n####=========================####\n";
printf "#### BEGIN GRAPH COMPILATION ####\n";
printf "####=========================####\n\n";

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

for x in exp/*/decode*; do
    [ -d $x ] && grep WER $x/wer_* | utils/best_wer.sh;
done
