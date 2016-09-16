#!/usr/bin/env bash

# This script will:
# (1) pre-process text for use in language model using `tools/lm_pre/preprocess_for_lm.py`
# (2) build a new language model using `tools/lm_pre/create_lm.sh`
# NOTE: If supplying existing language model, begins at step 3
# (3) identify OOV words from current lexicon using `tools/lm_pre/find_not_in_lexicon_arpa.py`
# (4) build a new lexicon using `g2p_phonemic_transcription_for_oov.sh`
# (5) merge lexicons using `tools/lexicon_pre/merge_lexicons.py`
# (6) ensure phones list is still accurate using `tools/lexicon_pre/check_phones_in_lexicon.py`

# ARGUMENTS
# REQUIRED
# -x <path> = full path to `lexicon.txt` file
# -p <path> = full path to `phones.txt` file
# -m <path> = full path to `irstlm` installed
# -n <path> = full path to `g2p` installed
# -g <path> = full path to `g2p` model to be used
# -i <string> = list of paths to multiple `.txt` files to use in building language model
    # use " " to make a list of files
# -o <string> = full path to folder for outputting files

# OPTIONAL
# -z <path> = full path to already-created language model
    # will skip steps building language model
# -r <no argument> = preprocess text?, default = `false`
# -l <no argument> = if present, consider original documents "line-separated"
# -n <no argument> = rejoin contractions?, default = `false`
# -s <no argument> = use <s> and </s> symbols?, default = `false`
# -c <no argument> = compress language model?, default = `false}
# -t <string> = full path to `tmp` folder, default = `/tmp/kaldi_lm_process/`

# default values for variables
preprocess=false
contractions=False
segment=false
compress=false
temp=/tmp/kaldi_lm_process/
line_separated=false
existing_lm=


while getopts "x:p:m:n:g:i:rnsct:o:lz:" opt; do
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
        n)
            g2p_path=${OPTARG}
            ;;
        g)
            g2p_model=${OPTARG}
            ;;
        i)
            files_in=(${OPTARG})
            ;;
        r)
            preprocess=true
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
        l)
            line_separated=true
            ;;
        z)
            existing_lm=${OPTARG}
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

# remove temp if already exists
rm -rf ${temp}
# make temp folder
mkdir -p ${temp}
# make output folder
mkdir -p ${folder_out}

if [ -z "${existing_lm}" ];then

    file_counter=0
    clean_files=()

    # save clean output as #.txt
    for f in "${files_in[@]}"; do
        # update counter
        file_counter=$((file_counter + 1))
        # make full path
        file_path=${temp}${file_counter}.txt
        # add to array of clean files
        clean_files+=(${file_path})
        if [ "${preprocess}" = true ]; then
            echo "preprocessing document" ${file_counter}
            if [ "${line_separated}" = true ]; then
                python ${PATH_TO_KALDI}/tools/nextiva_tools/lm_pre/preprocess_for_lm.py \
                    ${f} \
                    ${file_path} \
                    ${contractions} \
                    True
            else
                python ${PATH_TO_KALDI}/tools/nextiva_tools/lm_pre/preprocess_for_lm.py \
                    ${f} \
                    ${file_path} \
                    ${contractions} \
                    False
            fi
        else
            echo "skipping preprocessing of document ${file_counter}"
            cp ${f} ${file_path}
        fi
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
        ${PATH_TO_KALDI}/tools/nextiva_tools/lm_pre/create_lm.sh \
            -m ${irstlm_path} \
            -o ${folder_out}lm.arpa \
            -s \
            -c \
            -i "${clean_files_list}"
    elif [ "${segment}" = false ] && [ "${compress}" = false ]; then
        ${PATH_TO_KALDI}/tools/nextiva_tools/lm_pre/create_lm.sh \
            -m ${irstlm_path} \
            -o ${folder_out}lm.arpa \
            -i "${clean_files_list}"
    elif [ "${segment}" = true ] && [ "${compress}" = false ]; then
        ${PATH_TO_KALDI}/tools/nextiva_tools/lm_pre/create_lm.sh \
            -m ${irstlm_path} \
            -o ${folder_out}lm.arpa \
            -s \
            -i "${clean_files_list}"
    else
        ${PATH_TO_KALDI}/tools/nextiva_tools/lm_pre/create_lm.sh \
            -m ${irstlm_path} \
            -o ${folder_out}lm.arpa \
            -i "${clean_files_list}"
    fi

    printf "Timestamp in HH:MM:SS (24 hour format)\n";
    date +%T
    printf "\n"

else
    echo "using existing language model at ${existing_lm}"
    cp ${existing_lm} ${folder_out}lm.arpa
fi

echo "Comparing language model to lexicon"

if [ "${compress}" = true ]; then
    python ${PATH_TO_KALDI}/tools/nextiva_tools/lm_pre/find_not_in_lexicon_arpa.py \
        ${folder_out}lm.arpa \
        True \
        ${lexicon} \
        ${temp}oov.txt
else
    python ${PATH_TO_KALDI}/tools/nextiva_tools/lm_pre/find_not_in_lexicon_arpa.py \
        ${folder_out}lm.arpa \
        False \
        ${lexicon} \
        ${temp}oov.txt
fi

if [ ! -s ${temp}oov.txt ]; then
    echo "Lexicon contains all words in language model"
    # copy existing lexicon to out folder
    cp ${lexicon} ${folder_out}lexicon-withDups.txt
else
    echo "Out-of-vocabulary words found in language model have been written to" ${temp}oov.txt
    echo "Automatically transcribing out-of-vocabulary words"
    # split into files of 10 lines each
    split -l 10 ${temp}oov.txt ${temp}oov-part. --additional-suffix=.txt
    for f in ${temp}oov-part.*; do
        # get the basename
        base=$(basename ${f})
        # get the extension
        ext=${base##*t}
        echo "transcribing OOV for part ${ext}"
        ${PATH_TO_KALDI}/tools/nextiva_tools/lexicon_pre/g2p_phonemic_transcription_for_oov.sh \
            -i ${f} \
            -o ${temp}oov-lex-part${ext} \
            -m ${g2p_model} \
            -g ${g2p_path}
    done
    # concatenate oov-lex-part.* back together
    for part in ${temp}oov-lex-part.*; do
        cat ${part};
    done > ${temp}oov-lex.txt
    echo "Building a new lexicon"
    # find any items that were unsuccessfully transcribed by `g2p`
    cut -d' ' -f1 ${temp}oov-lex.txt > ${temp}oov-transcribed.txt
    comm -23 <(sort ${temp}oov.txt) <(sort ${temp}oov-transcribed.txt) > ${temp}oov-not-transcribed.txt
    #add a filler line (of transcription "NG NG NG NG") for any word not transcribed by `g2p`
    while read line; do
        echo -e "${line} NG NG NG NG" >> ${temp}oov-lex.txt
    done <${temp}oov-not-transcribed.txt
    # sort oov-lex.txt
    sort ${temp}oov-lex.txt -o ${temp}oov-lex.txt
    # merge lexicons
    python ${PATH_TO_KALDI}/tools/nextiva_tools/lexicon_pre/merge_lexicons.py \
        ${folder_out}lexicon-withDups.txt \
        ${lexicon} \
        ${temp}oov-lex.txt
fi

# add <unk> SPOKEN_NOISE
echo -e "<unk>\tSPOKEN_NOISE" >> ${folder_out}lexicon-withDups.txt
# remove duplicates
${PATH_TO_KALDI}/tools/nextiva_tools/misc/remove_duplicates.sh \
    ${folder_out}lexicon-withDups.txt \
    ${folder_out}lexicon.txt

echo "Updating phones list"
python ${PATH_TO_KALDI}/tools/nextiva_tools/lexicon_pre/check_phones_in_lexicon.py \
    ${folder_out}lexicon.txt \
    ${phones} \
    ${folder_out}phones.txt

echo "Building lexicon_nosil"
${PATH_TO_KALDI}/tools/nextiva_tools/lexicon_pre/make_lexicon_nosil.sh \
    ${folder_out}lexicon.txt \
    ${folder_out}lexicon_nosil.txt

# removing temp folder
#rm -rf ${temp}

