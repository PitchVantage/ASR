#!/usr/bin/env bash

# This script will:
# (1) pre-process text for use in language model using `tools/lm_pre/preprocess_for_lm.py`
# (2) build a new language model using `tools/lm_pre/create_lm.sh`
# (3) identify OOV words from current lexicon using `tools/lm_pre/find_not_in_lexicon_arpa.py`
# (4) build a new lexicon using `???`
# (5) merge lexicons using `tools/lexicon_pre/merge_lexicons.py`
# (6) ensure phones list is still accurate using `tools/lexicon_pre/check_phones_in_lexicon.py`

# -x <path> = full path to `lexicon.txt` file
# -p <path> = full path to `phones.txt` file
# -m <string> = full path to irstlm installed
# -i <string> = list of paths to multiple `.txt` files to use in building language model
# -o <string> = full path to folder for outputting files (must end in `/`)
# -n <no argument> = rejoin contractions?, default = `false`
# use " " to make a list of files
# -s <no argument> = use <s> and </s> symbols?, default = `false`
# -c <no argument> = compress language model?, default = `false
# -t <string> = full path to `tmp` folder, default = `/tmp/kaldi_lm_process/`

# default values for variables
contractions=False
segment=false
compress=false
temp=/tmp/kaldi_lm_process/


while getopts "x:p:m:i:nsct:o:" opt; do
    case ${opt} in
        x)
            lexicon=${OPTARG}
            ;;
        p)
            phones=${OPTARG}
            ;;
        m)
            irstlm_path=${OPTARG}
            ;;
        i)
            files_in=(${OPTARG})
            ;;
        n)
            contractions=True
            ;;
        s)
            segment=true
            ;;
        c)
            compress=true
            ;;
        t)
            temp=${OPTARG}/
            ;;
        o)
            folder_out=${OPTARG}/
            ;;
        \?)
            echo "Please use correct flags"
            exit 1
            ;;
    esac
done


printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"

# make temp folder
mkdir -p ${temp}
# make output folder
mkdir -p ${folder_out}

# preprocess files
echo "Preprocessing incoming .txt files"

file_counter=0
clean_files=()

# save clean output as #.txt
for f in "${files_in[@]}"; do
    # update counter
    file_counter=$((file_counter + 1))
    echo "processing document" ${file_counter}
    # make full path
    file_path=${temp}${file_counter}.txt
    # add to array of clean files
    clean_files+=(${file_path})
    python ../../tools/nextiva_tools/lm_pre/preprocess_for_lm.py \
        ${f} \
        ${file_path} \
        ${contractions} \
        False
done

printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"

# make string out of $clean_files
clean_files_list=$( IFS=$' '; echo "${clean_files[*]}" )

# build new language model
echo "Building language model from cleaned .txt files"
echo "Saving to" ${folder_out}"lm.arpa"

if [ "${segment}" = true ] && [ "${compress}" = true ]; then
    ../../tools/nextiva_tools/lm_pre/create_lm.sh \
        -m ${irstlm_path} \
        -o ${folder_out}lm.arpa \
        -s \
        -c \
        -i "${clean_files_list}"
elif [ "${segment}" = false ] && [ "${compress}" = false ]; then
    ../../tools/nextiva_tools/lm_pre/create_lm.sh \
        -m ${irstlm_path} \
        -o ${folder_out}lm.arpa \
        -i "${clean_files_list}"
elif [ "${segment}" = true ] && [ "${compress}" = false ]; then
    ../../tools/nextiva_tools/lm_pre/create_lm.sh \
        -m ${irstlm_path} \
        -o ${folder_out}lm.arpa \
        -s \
        -i "${clean_files_list}"
else
    ../../tools/nextiva_tools/lm_pre/create_lm.sh \
        -m ${irstlm_path} \
        -o ${folder_out}lm.arpa \
        -i "${clean_files_list}"
fi

printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"



echo "Comparing language model to lexicon"

if [ "${compress}" = true ]; then
    python ../../tools/nextiva_tools/lm_pre/find_not_in_lexicon_arpa.py \
        ${folder_out}lm.arpa \
        True \
        ${lexicon} \
        ${temp}oov.txt
else
    python ../../tools/nextiva_tools/lm_pre/find_not_in_lexicon_arpa.py \
        ${folder_out}lm.arpa \
        False \
        ${lexicon} \
        ${temp}oov.txt
fi

if [ ! -s ${temp}oov.txt ]; then
    echo "Lexicon contains all words in language model"
    # copy existing lexicon to out folder
    cp ${lexicon} ${folder_out}lexicon.txt
else
    echo "Out-of-vocabulary words found in language model have been written to" ${temp}oov.txt
    # TODO send ${temp}oov.txt to phonemic transcriber
    echo "Building a new lexicon"
    python ../../tools/nextiva_tools/lm_pre/merge_lexicons.py \
        ${folder_out}lexicon.txt \
        ${lexicon} \
        # TODO put output of phonemic transcriber here
fi

echo "Updating phones list"
python ../../tools/nextiva_tools/lm_pre/check_phones_in_lexicon.py \
    ${folder_out}lexicon.txt \
    ${phones} \
    ${folder_out}phones.txt

echo "Building lexicon_nosil"
../../tools/nextiva_tools/lexicon_pre/make_lexicon_nosil.sh ${folder_out}lexicon.txt ${folder_out}lexicon_nosil.txt

# removing temp folder
rm -rf ${temp}

