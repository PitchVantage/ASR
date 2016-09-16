#!/usr/bin/env bash

# This script will generate predicted transcriptions for test data found in `nextiva_recipes/data/test_dir`

# ARGUMENTS
### REQUIRED
# -g <path> = full path to graph directory, default=`exp/triphones/graph/`
# -t <path> = full path to test data dir, default=`data/test_dir/`
# -d <path> = full path to decode dir (housing final model - `*.mdl`), default=`exp/triphones/decode_test_dir/`
### OPTIONAL
# -j <int> = number of processors to use, default=2
# -w <int> = lattice weight to use when returning transcription, default = `10`
# -q <string> = non-vanilla hyperparameters to `decode.sh`, in the form "--beam 20"

# OUTPUTS
# Creates one or more subdirectories in `data/test_dir/split*/` equal to setting of `-j` where
# files are copied for each parallel process
# Creates a `decode` directory, usually `exp/triphones/decode_test_dir/`

# default values for variables
num_processors=2
graph_dir=${PATH_TO_KALDI}/egs/nextiva_recipes/exp/triphones/graph/
data_test_dir=${PATH_TO_KALDI}/egs/nextiva_recipes/data/test_dir/
decode_dir=${PATH_TO_KALDI}/egs/nextiva_recipes/exp/triphones/decode_test_dir/
weight=10
hyperparameters=

rm -rf ${decode_dir}

while getopts "j:g:t:d:w:q:" opt; do
    case ${opt} in
        j)
            num_processors=${OPTARG}
            ;;
        g)
            graph_dir=${OPTARG}
            ;;
        t)
            data_test_dir=${OPTARG}
            ;;
        d)
            decode_dir=${OPTARG}
            ;;
        w)
            weight=${OPTARG}
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

#Print timestamp in HH:MM:SS (24 hour format)
printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"

srcdir=`dirname ${decode_dir}`;
model=${srcdir}/final.mdl

# identify lattice weights to use
weight_lower=$(expr ${weight} - 1)
weight_upper=$(expr ${weight} + 1)

${PATH_TO_KALDI}/egs/nextiva_recipes/steps/decode.sh \
    ${hyperparameters} \
    --model ${model} \
    --nj ${num_processors} \
    --scoring-opts "--min-lmwt ${weight_lower} --max-lmwt ${weight_upper}" \
    ${graph_dir} \
    ${data_test_dir} \
    ${decode_dir} \
    || (printf "\n####\n#### ERROR: decode.sh \n####\n\n" && exit 1);


#Print timestamp in HH:MM:SS (24 hour format)
printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"

# outputs transcript
for x in ${decode_dir}/scoring/${weight}.tra; do
    ${PATH_TO_KALDI}/egs/nextiva_recipes/utils/int2sym.pl -f 2- ${PATH_TO_KALDI}/egs/nextiva_recipes/exp/triphones/graph/words.txt ${x} \
        || (printf "\n####\n#### ERROR: int2sym.pl\n####\n\n" && exit 1);
done
echo

# calculates *best* WER (from three runs)
for x in ${decode_dir}; do
    [ -d ${x} ] && grep WER ${x}/wer_* | ${PATH_TO_KALDI}/egs/nextiva_recipes/utils/best_wer.sh \
        || (printf "\n####\n#### ERROR: best_wer.sh\n####\n\n" && exit 1);
done