#!/usr/bin/env bash

# This script generates MFCCs and cmvn statistics (TODO is this speaker identification?)

# Creates `exp/` directory for logs and `mfcc/` directory for `mfcc`s

# -j <int> = number of processors to use, default=2
# must have *one* of the following
# -n [no argument] = simply if training data is present
# -t [no argument] = simply if testing data is present

# default values for variables
train_dir=""
test_dir=""
num_processors=2

while getopts "ntj:" opt; do
    case ${opt} in
        n)
            # update variable $train_dir
            train_dir=train_dir
            ;;
        t)
            # update variable $test_dir
            test_dir=test_dir
            ;;
        j)
            # update number of processors used
            num_processors=${OPTARG}
            ;;
        \?)
            echo "Wrong flags"
            exit 1
            ;;
    esac
done

printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"

for dir in ${train_dir} ${test_dir}; do

    steps/make_mfcc.sh --nj ${num_processors} \
        data/${dir} \
        exp/make_mfcc/${dir} \
        mfcc \
        || printf "\n####\n#### ERROR: make_mfcc.sh \n####\n\n";

    steps/compute_cmvn_stats.sh \
        data/${dir} \
        exp/make_mfcc/${dir} \
        mfcc \
        || printf "\n####\n#### ERROR: compute_cmvn_stats.sh \n####\n\n";
done

printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"