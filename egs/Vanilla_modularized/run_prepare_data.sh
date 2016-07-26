#!/usr/bin/env bash

# This scripts prepares the data (audio, transcripts, phones list, language model) for later use
# Creates `data/` directory

# *Note:* This script can take training and/or testing audio

# -r <path> = full path to `transcripts` file
# NOTE: if flag *not* present, assumes segmented transcript files
# -x <path> = full path to `lexicon.txt` file
# -y <path> = full path to `lexicon_nosil.txt` file
# -p <path> = full path to `phones.txt` file
# -l <path> = full path to `language_model` file
# -n <path> = full path of training data
# -t <path> = full path of testing data
# -u [no argument] = if present, using UNsegmented transcript file
# -g <path> = full path to TRAIN segments file  **needed if *not -u*
# -h <path> = full path to TEST segments file   **needed if *not -u*

# default values for variables
train_dir=""
test_dir=""
segmented=true

while getopts "r:ux:y:p:l:n:t:g:h:" opt; do
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
            segmentsTRAIN=${OPTARG}
            ;;
        h)
            segmentsTEST=${OPTARG}
            ;;
        \?)
            echo "Please use flag -n and/or -t"
            exit 1
            ;;
    esac
done

printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"

# run local/prepare_data.sh
if [[ ${train_dir} != "" && ${test_dir} != "" ]]; then
    if [ "${segmented}" = true ]; then
        local/prepare_data.sh -r ${transcripts} -x ${lexicon} -y ${lexicon_nosil} -p ${phones} \
            -l ${language_model} -n ${train_dir} -t ${test_dir} -g ${segmentsTRAIN} -h ${segmentsTEST} \
            || printf "\n####\n#### ERROR: prepare_data.sh\n####\n\n";
        utils/fix_data_dir.sh data/train_dir
        utils/fix_data_dir.sh data/test_dir
    else
        local/prepare_data.sh -r ${transcripts} -x ${lexicon} -y ${lexicon_nosil} \
        -p ${phones} -l ${language_model} -n ${train_dir} -t ${test_dir} -u \
        || printf "\n####\n#### ERROR: prepare_data.sh\n####\n\n";
    fi
elif [[ ${train_dir} != "" && ${test_dir} == "" ]]; then
    if [ "${segmented}" = true ]; then
        local/prepare_data.sh -r ${transcripts} -x ${lexicon} -y ${lexicon_nosil} -p ${phones} \
            -l ${language_model} -n ${train_dir} -g ${segmentsTRAIN} \
            || printf "\n####\n#### ERROR: prepare_data.sh\n####\n\n";
        utils/fix_data_dir.sh data/train_dir
    else
        local/prepare_data.sh -r ${transcripts} -x ${lexicon} -y ${lexicon_nosil} -p ${phones} \
            -l ${language_model} -n ${train_dir} -u \
            || printf "\n####\n#### ERROR: prepare_data.sh\n####\n\n";
    fi
elif [[ ${test_dir} != "" && ${train_dir} == "" ]]; then
    if [ "${segmented}" = true ]; then
        local/prepare_data.sh -r ${transcripts} -x ${lexicon} -y ${lexicon_nosil} -p ${phones} \
            -l ${language_model} -t ${test_dir} -h ${segmentsTEST}\
            || printf "\n####\n#### ERROR: prepare_data.sh\n####\n\n";
        utils/fix_data_dir.sh data/test_dir
    else
        local/prepare_data.sh -r ${transcripts} -x ${lexicon} -y ${lexicon_nosil} -p ${phones} \
            -l ${language_model} -t ${test_dir} -u \
            || printf "\n####\n#### ERROR: prepare_data.sh\n####\n\n";
    fi
fi

# run utils/prepare_lang.sh
utils/prepare_lang.sh --position-dependent-phones false \
    data/local/dict \
    "<unk>" \
    data/local/lang \
    data/lang \
    || printf "\n####\n#### ERROR: prepare_lang.sh\n####\n\n";

# run local/prepare_lm.sh
# creates `data/lang_test_tg
local/prepare_lm.sh -l ${language_model} \
    || printf "\n####\n#### ERROR: prepare_lm.sh\n####\n\n";


printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"