#!/usr/bin/env bash

# This script prepares the data for training by formatting input data properly.
# NOTE: This script can be run with or without testing data

# -r = full path to `transcripts` file
# NOTE: if flag *not* present, assumes segmented transcript files
# -x = full path to `lexicon.txt` file
# -y = full path to `lexicon_nosil.txt` file
# -p = full path to `phones.txt` file
# -l = full path to `language_model` file
# -n = full path of training data
# -t = full path of testing data
# -u = using UNsegmented transcript file [optional]
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
        y)
            lexicon_nosil=${OPTARG}
            ;;
        p)
            phones=${OPTARG}
            ;;
        l)
            language_model=${OPTARG}
            ;;
        n)
            # update variable $train_dir
            train_dir=${OPTARG}
            ;;
        t)
            # update variable $test_dir
            test_dir=${OPTARG}
            ;;
        g)
            segmentsTRAIN=${OPTARG}
            ;;
        h)
            segmentsTEST=${OPTARG}
            ;;
        \?)
            echo "Wrong flags"
            exit 1
            ;;
    esac
done

# make nextiva_recipes/data/local/
# `-p` = makes /data/ first if needed
mkdir -p data/local

echo "Preparing data"

# write `waves.train` and/or `waves.test` files
if [[ ${train_dir} != "" ]]; then
    ls -1 ${train_dir} > data/local/waves.train
fi
if [[ ${test_dir} != "" ]]; then
    ls -1 ${test_dir} > data/local/waves.test
fi

# sort files by bytes (kaldi-style) and re-save them with original filename
#for file in waves.test waves.train; do
for file in data/local/waves.test data/local/waves.train; do
    if [[ -e ${file} ]]; then
        LC_ALL=C sort -i ${file} -o ${file};
    fi
done

##Sort train segments file
#for fileName in segments; do
#LC_ALL=C sort -i data/train_dir/$fileName -o data/train_dir/$fileName;
#done;
#
##Sort test segments file
#for fileName in segments; do
#LC_ALL=C sort -i data/test_dir/$fileName -o data/test_dir/$fileName;
#done;

for item in ${train_dir} ${test_dir}; do
    if [[ ${item} == ${train_dir} ]]; then
        # make a data/train_dir directory
        mkdir -p data/train_dir
        # make a two-column list of test utterance ids and their paths
        # TODO these paths are absolute (*not* inside egs/)
        local/create_wav_scp.pl ${train_dir} data/local/waves.train > data/train_dir/wav.scp
        # create separate transcription file
        # <utteranceID> <text>
        if [ "${segmented}" = true ]; then
            python local/create_txt_segments.py ${transcripts} data/local/waves.train > \
                data/train_dir/text
            cp ${segmentsTRAIN} data/train_dir/segments
        else
            local/create_txt.pl ${transcripts} data/local/waves.train > data/train_dir/text
        fi
        # TODO what do these lines do?
        cat data/train_dir/text | awk '{printf("%s %s\n", $1, $1);}' > data/train_dir/utt2spk
#        cat data/train_dir/segments | awk '{printf("%s %s\n", $1, $1);}' > data/train_dir/utt2spk
        utils/utt2spk_to_spk2utt.pl <data/train_dir/utt2spk >data/train_dir/spk2utt
    elif [[ ${item} == ${test_dir} ]]; then
        # make a data/test_dir directory
        mkdir -p data/test_dir
        # make a two-column list of test utterance ids and their paths
        # TODO these paths are absolute (*not* inside egs/)
        local/create_wav_scp.pl ${test_dir} data/local/waves.test > data/test_dir/wav.scp
        # create separate transcription file
        # <utteranceID> <text>
        if [ "${segmented}" = true ]; then
            python local/create_txt_segments.py ${transcripts} data/local/waves.test > \
                data/test_dir/text
            cp ${segmentsTEST} data/test_dir/segments
        else
            local/create_txt.pl ${transcripts} data/local/waves.test > data/test_dir/text
        fi
        # TODO what do these lines do?
        cat data/test_dir/text | awk '{printf("%s %s\n", $1, $1);}' > data/test_dir/utt2spk
#        cat data/test_dir/segments | awk '{printf("%s %s\n", $1, $1);}' > data/test_dir/utt2spk
        utils/utt2spk_to_spk2utt.pl <data/test_dir/utt2spk >data/test_dir/spk2utt
    fi

done

# copy language model file into data/local/
cp ${language_model} data/local/lm_tg.arpa

# make nextiva_recipes/data/local/dict
# `-p` = makes /data/ and /data/local/ first if needed
mkdir -p data/local/dict

# the following three steps replace `/local/prepare_dict.sh`
# copy lexicon files into data/local/dict
cp ${lexicon} data/local/dict/lexicon.txt
cp ${lexicon_nosil} data/local/dict/lexicon_words.txt

# remove SIL from phones if present and copy to data/local/dict
cat ${phones} | grep -v SIL > data/local/dict/nonsilence_phones.txt

# make lists of silence phones
echo "SIL" > data/local/dict/silence_phones.txt
echo "SIL" > data/local/dict/optional_silence.txt
