#!/usr/bin/env bash

# This scripts updates the original files stored during `run_prepare_data.sh`.

# -x = full path to `lexicon.txt` file
# -y = full path to `lexicon_nosil.txt` file
# -p = full path to `phones.txt` file
# -l = full path to `language_model` file
# -d = full path to `data/` folder, default = `data/`

#default variables
lexicon=
lexicon_nosil=
phones=
language_model=
data_folder=data/

while getopts "x:y:p:l:d:" opt; do
    case ${opt} in
        x)
            lexicon=${OPTARG}
            ;;
        y)
            lexicon_nosil=${OPTARG}
            ;;
        p)
            phones=${OPTARG}
            ;;
        l)
            language_model=${OPTARG}
            ;;
        d)
            data_folder=${OPTARG}/
            ;;
        \?)
            echo "Wrong flags"
            exit 1
            ;;
    esac
done

# these steps are the last portion of the `run_prepare_data.sh` script

if [ ! -z "${lexicon}" ]; then
    echo "updating lexicon.txt found in ${data_folder}local/dict"
    cp ${lexicon} ${data_folder}local/dict/lexicon.txt
fi

if [ ! -z "${lexicon_nosil}" ]; then
    echo "updating lexicon_words.txt found in ${data_folder}local/dict"
    cp ${lexicon_nosil} ${data_folder}local/dict/lexicon_words.txt
fi

if [ ! -z "${phones}" ]; then
    echo "updating nonsilence_phones.txt found in ${data_folder}local/dict"
    cat ${phones} | grep -v SIL > ${data_folder}local/dict/nonsilence_phones.txt
fi

if [ ! -z "${language_model}" ]; then
    echo "updating language model, lm_tg.arpa found in ${data_folder}local/"
    cp ${language_model} ${data_folder}local/lm_tg.arpa
fi

# re-run utils/prepare_lang.sh
utils/prepare_lang.sh \
    --position-dependent-phones false \
    ${data_folder}local/dict \
    "<unk>" \
    ${data_folder}local/lang \
    ${data_folder}lang \
    || printf "\n####\n#### ERROR: prepare_lang.sh\n####\n\n";

# re-run local/prepare_lm.sh
local/prepare_lm.sh \
    -l ${language_model} \
    || printf "\n####\n#### ERROR: prepare_lm.sh\n####\n\n";


