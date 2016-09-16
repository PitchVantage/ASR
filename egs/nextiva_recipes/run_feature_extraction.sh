#!/usr/bin/env bash

# This script generates MFCCs and cmvn statistics (TODO is this speaker identification?)

# ARGUMENTS
# REQUIRED
# -c <path> = path to `.conf` file
# -n [no argument] = simply if training data is present
# -t [no argument] = simply if testing data is present
# Must have *at least* one of `-n` or `-t`
# OPTIONAL
# -j <int> = number of processors to use, default=2
# -q <string> = non-vanilla hyperparameters to `compute_cmvn_stats.sh`, in the form "--fake-dims 13:14"

# OUTPUTS
# Creates:
    # `mfcc/` directory for the `mfcc`s from training data
    # `exp/` for logs
    # `data/{train,test}dir/{feats,cmvn}.scp` which are required when running `run_train_phones.sh`

# default values for variables
train_dir=""
test_dir=""
num_processors=2
conf=
hyperparameters=

while getopts "ntj:c:q:" opt; do
    case ${opt} in
        n)
            train_dir=train_dir
            ;;
        t)
            test_dir=test_dir
            ;;
        j)
            num_processors=${OPTARG}
            ;;
        c)
            conf=${OPTARG}
            ;;
        q)
            hyperparameters=${OPTARG}
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

    # run fix_data_dir just in case
#    utils/fix_data_dir.sh ${dir}

    # make mfccs
    ${PATH_TO_KALDI}/egs/nextiva_recipes/steps/make_mfcc.sh --nj ${num_processors} \
        --mfcc-config ${conf} \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/data/${dir} \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/exp/make_mfcc/${dir} \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/mfcc \
        || (printf "\n####\n#### ERROR: make_mfcc.sh \n####\n\n" && exit 1);

    # compute cmvn stats
    ${PATH_TO_KALDI}/egs/nextiva_recipes/steps/compute_cmvn_stats.sh \
        ${hyperparameters} \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/data/${dir} \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/exp/make_mfcc/${dir} \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/mfcc \
        || (printf "\n####\n#### ERROR: compute_cmvn_stats.sh \n####\n\n" && exit 1);
done

printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"