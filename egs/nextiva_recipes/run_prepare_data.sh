#!/usr/bin/env bash

# This scripts prepares the data (audio, transcripts, phones list, language model) for later use
# *Note:* This script can take training and/or testing audio

# ARGUMENTS
# REQUIRED
# -r <path> = full path to `transcripts` file
# NOTE: if flag *not* present, assumes segmented transcript files
# -x <path> = full path to `lexicon.txt` file
# -y <path> = full path to `lexicon_nosil.txt` file
# -p <path> = full path to `phones.txt` file
# -l <path> = full path to `language_model` file
# -n <path> = full path of training data
# -t <path> = full path of testing data
# Must have *at least* one of `-n` or `-t`
# OPTIONAL
# -u [no argument] = if present, using UNsegmented transcript file
# -g <path> = full path to TRAIN segments file  **needed if *not -u*
# -h <path> = full path to TEST segments file   **needed if *not -u*
# -q <string> = non-vanilla hyperparameters to `prepare_lang.sh`, in the form "--sil-prob .1"

# OUTPUTS
# Creates `data/` directory
# This includes subdirectories: `data/lang/`, `data/lang_test_tg/`, `data/local/`, and
# `data/train_dir` and/or `data/test_dir/`

# default values for variables
train_dir=""
test_dir=""
segmented=true
hyperparameters=

while getopts "r:ux:y:p:l:n:t:g:h:q:" opt; do
    case ${opt} in
        r)
            transcripts=${OPTARG}
            ;;
        u)
            segmented=false
            ;;
        x)
            lexicon=${OPTARG}
            ;;
        y)  lexicon_nosil=${OPTARG}
            ;;
        p)
            phones=${OPTARG}
            ;;
        l)
            language_model=${OPTARG}
            ;;
        n)
            train_dir=${OPTARG}
            ;;
        t)
            test_dir=${OPTARG}
            ;;
        g)
            segments_train=${OPTARG}
            ;;
        h)
            segments_test=${OPTARG}
            ;;
        q)
            hyperparameters=${OPTARG}
            ;;
        \?)
            echo "Please use correct flags"
            exit 1
            ;;
    esac
done

# remove any existing folders
rm -rf data/ mfcc/ exp/

printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"

# run local/prepare_data.sh
if [[ ${train_dir} != "" && ${test_dir} != "" ]]; then
    if [ "${segmented}" = true ]; then
        ${PATH_TO_KALDI}/egs/nextiva_recipes/local/prepare_data.sh \
            -r ${transcripts} \
            -x ${lexicon} \
            -y ${lexicon_nosil} \
            -p ${phones} \
            -l ${language_model} \
            -n ${train_dir} \
            -t ${test_dir} \
            -g ${segments_train} \
            -h ${segments_test} \
            || (printf "\n####\n#### ERROR: prepare_data.sh\n####\n\n" && exit 1);
        ${PATH_TO_KALDI}/egs/nextiva_recipes/utils/fix_data_dir.sh data/train_dir \
            || (printf "\n####\n#### ERROR: fix_data_dir.sh\n####\n\n" && exit 1);
        ${PATH_TO_KALDI}/egs/nextiva_recipes/utils/fix_data_dir.sh data/test_dir \
            || (printf "\n####\n#### ERROR: fix_data_dir.sh\n####\n\n" && exit 1);
    else
        ${PATH_TO_KALDI}/egs/nextiva_recipes/local/prepare_data.sh \
            -r ${transcripts} \
            -x ${lexicon} \
            -y ${lexicon_nosil} \
            -p ${phones} \
            -l ${language_model} \
            -n ${train_dir} \
            -t ${test_dir} \
            -u \
        || (printf "\n####\n#### ERROR: prepare_data.sh\n####\n\n" && exit 1);
    fi
elif [[ ${train_dir} != "" && ${test_dir} == "" ]]; then
    if [ "${segmented}" = true ]; then
        ${PATH_TO_KALDI}/egs/nextiva_recipes/local/prepare_data.sh \
            -r ${transcripts} \
            -x ${lexicon} \
            -y ${lexicon_nosil} \
            -p ${phones} \
            -l ${language_model} \
            -n ${train_dir} \
            -g ${segments_train} \
            || (printf "\n####\n#### ERROR: prepare_data.sh\n####\n\n" && exit 1);
        ${PATH_TO_KALDI}/egs/nextiva_recipes/utils/fix_data_dir.sh data/train_dir \
            || (printf "\n####\n#### ERROR: fix_data_dir.sh\n####\n\n" && exit 1);
    else
        ${PATH_TO_KALDI}/egs/nextiva_recipes/local/prepare_data.sh \
            -r ${transcripts} \
            -x ${lexicon} \
            -y ${lexicon_nosil} \
            -p ${phones} \
            -l ${language_model} \
            -n ${train_dir} \
            -u \
            || (printf "\n####\n#### ERROR: prepare_data.sh\n####\n\n" && exit 1);
    fi
elif [[ ${test_dir} != "" && ${train_dir} == "" ]]; then
    if [ "${segmented}" = true ]; then
        ${PATH_TO_KALDI}/egs/nextiva_recipes/local/prepare_data.sh \
            -r ${transcripts} \
            -x ${lexicon} \
            -y ${lexicon_nosil} \
            -p ${phones} \
            -l ${language_model} \
            -t ${test_dir} \
            -h ${segments_test} \
            || (printf "\n####\n#### ERROR: prepare_data.sh\n####\n\n" && exit 1);
        ${PATH_TO_KALDI}/egs/nextiva_recipes/utils/fix_data_dir.sh data/test_dir \
            || (printf "\n####\n#### ERROR: fix_data_dir.sh\n####\n\n" && exit 1);
    else
        ${PATH_TO_KALDI}/egs/nextiva_recipes/local/prepare_data.sh \
            -r ${transcripts} \
            -x ${lexicon} \
            -y ${lexicon_nosil} \
            -p ${phones} \
            -l ${language_model} \
            -t ${test_dir} \
            -u \
            || (printf "\n####\n#### ERROR: prepare_data.sh\n####\n\n" && exit 1);
    fi
else
    printf "\n####\n#### ERROR: Neither training nor testing data provided\n####\n\n" && exit 1
fi

# run utils/prepare_lang.sh
${PATH_TO_KALDI}/egs/nextiva_recipes/utils/prepare_lang.sh \
    ${hyperparameters} \
    --position-dependent-phones false \
    ${PATH_TO_KALDI}/egs/nextiva_recipes/data/local/dict \
    "<unk>" \
    ${PATH_TO_KALDI}/egs/nextiva_recipes/data/local/lang \
    ${PATH_TO_KALDI}/egs/nextiva_recipes/data/lang \
    || (printf "\n####\n#### ERROR: prepare_lang.sh\n####\n\n" && exit 1);

# run local/prepare_lm.sh
# creates `data/lang_test_tg
${PATH_TO_KALDI}/egs/nextiva_recipes/local/prepare_lm.sh \
    -l ${language_model} \
    || (printf "\n####\n#### ERROR: prepare_lm.sh\n####\n\n" && exit 1);


printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"