#!/usr/bin/env bash

# This script predicts a *single* transcription from a *single* novel audio.

# This script will assume that the necessary items are in `nextiva_recipes/{exp, mfcc}` unless
# updated.

# TODO add capacity to parallelize `decode_for_predict.sh` if segmented
# TODO add timestamps and confidence (in `score_no_wer.sh`) and output as .json
# TODO streamline - remove all unnecessary steps (such as logging etc)

###REQUIRED INPUT
# -a <path> = full path to audio file to be transcribed
# -g <path> = full path to existing `graph`, default = `exp/triphones/graph/HCLG.fst`
# -l <path> = full path to the lexicon lookup file, default = `exp/triphones/graph/words.txt`
# -o <path> = full path to the model (`.mdl`) file, default = `exp/triphones/final.mdl`

###REQUIRED OUTPUT
# -d <path> = directory to house files generated by this process, default = `exp/triphones/decode_test_dir`
# -m <path> = directory to house output mfccs from this process if are to be kept after decoding

###OPTIONAL TEMPORARY
# -t <path> = full path to temp folder, default = `/tmp/kaldi_decode/
# -u <no argument> = if present, audio will remain *unsegmented*

###OPTIONAL HYPERPARAMETER
# -w <int> = lattice weight to use during scoring, default = `10`

# default variables
segmented=true
temp=/tmp/kaldi_decode/
graph=exp/triphones/graph/HCLG.fst
words=exp/triphones/graph/words.txt
model=exp/triphones/final.mdl
decode_test_dir=exp/triphones/decode_test_dir
weight=10

# place new mfcc's into temp folder to be deleted after process
mfcc_dir=${temp}mfcc/
mkdir -p ${mfcc_dir}

while getopts "a:t:g:l:o:d:m:w:u" opt; do
    case ${opt} in
        a)
            audio_path=${OPTARG}
            ;;
        t)
            temp=${OPTARG}/
            ;;
        g)
            graph=${OPTARG}
            ;;
        l)
            words=${OPTARG}
            ;;
        o)
            model=${OPTARG}
            ;;
        d)
            decode_test_dir=${OPTARG}/
            ;;
        m)
            mfcc_dir=${OPTARG}/
            mkdir -p ${mfcc_dir}
            ;;
        w)
            weight=${OPTARG}
            ;;
        u)
            segmented=false
            ;;
        \?)
            echo "Wrong flags"
            exit 1
            ;;
    esac
done

# make sure folders don't already exist
rm -rf ${temp}
rm -rf ${decode_test_dir}

# create necessary directories
mkdir -p ${temp}log ${temp}data

# build utt_id
utt_id=$(basename ${audio_path} .wav)

# build wav.scp
echo ${utt_id} ${audio_path} > ${temp}data/wav.scp

if [ "${segmented}" = true ]; then
# if audio is to be *segmented*
    # run diarization
    # TODO how to limit to 2 speakers? `--cMinimumOfCluster` isn't working
    java -Xmx1g -jar ../../tools/PVacoustic_pre/LIUM_SpkDiarization-8.4.1.jar \
        --fInputMask=${audio_path} \
        --sOutputMask=${temp}data/segments_raw.seg \
        --cMinimumOfCluster=2 \
        --doCEClustering ${audio_path}
    # format transcripts file
    python ../../tools/PVacoustic_pre/LIUM_seg_to_kaldi_seg.py \
        ${temp}data/segments_raw.seg \
        ${temp}data/segments \
        True
    # sort segments file
    LC_ALL=C sort -i ${temp}data/segments -o ${temp}data/segments
    # build utt2spk
    cat ${temp}data/segments | awk '{printf("%s %s\n", $1, $1);}' > ${temp}data/utt2spk
else
# if audio is to remain *unsegmented*
    # build utt2spk
    echo ${utt_id} ${utt_id} > ${temp}data/utt2spk
fi

# build spk2utt from utt2spk
utils/utt2spk_to_spk2utt.pl <${temp}data/utt2spk >${temp}data/spk2utt

# make mfccs
    # requires only one thread so that splitting doesn't occur
    # outputs files called `raw_mfcc_data.1.{ark,scp}`
steps/make_mfcc.sh --nj 1 \
        ${temp}data \
        ${temp}log \
        ${mfcc_dir} \
        || (printf "\n####\n#### ERROR: make_mfcc.sh \n####\n\n" && exit 1);

# computes cmnv stats
    # outputs files called `cvmn_data.{ark,scp}`
steps/compute_cmvn_stats.sh \
        ${temp}data \
        ${temp}log \
        ${mfcc_dir} \
        || (printf "\n####\n#### ERROR: compute_cmvn_stats.sh \n####\n\n" && exit 1);

# decode
steps/decode_for_predict.sh \
    --words ${words} \
    --graph ${graph} \
    --model ${model} \
    ${temp}data \
    ${decode_test_dir} \
    || (printf "\n####\n#### ERROR: decode_for_predict.sh \n####\n\n" && exit 1);

# output transcription
local/score_no_wer.sh \
    --min_lmwt ${weight} \
    --max_lmwt ${weight} \
    --words ${words} \
    ${temp}data \
    ${decode_test_dir} |\
    cut -d " " -f2- \
    || (printf "\n####\n#### ERROR: score_no_wer.sh \n####\n\n" && exit 1);

# remove temp
rm -rf ${temp}