#!/usr/bin/env bash

# This script will generate predicted transcriptions for test data found in `nextiva_recipes/data/test_dir`

# -j <int> = number of processors to use, default=2
# -g <path> = full path to graph directory, default=`exp/triphones/graph`
# -t <path> = full path to test data dir, default=`data/test_dir`
# -d <path> = full path to decode dir (housing final model - `*.mdl`), default=`exp/triphones/decode_test_dir`
# -w <int> = lattice weight to use when returning transcription, default = `10`

# default values for variables
num_processors=2
graph_dir=exp/triphones/graph
data_test_dir=data/test_dir
decode_dir=exp/triphones/decode_test_dir
weight=10

rm -rf ${decode_dir}

while getopts "j:g:t:d:w:" opt; do
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

# identify lattice weights to use
weight_lower=$(expr ${weight} - 1)
weight_upper=$(expr ${weight} + 1)

steps/decode.sh \
    --nj ${num_processors} \
    --scoring-opts "--min-lmwt ${weight_lower} --max-lmwt ${weight_upper}" \
    ${graph_dir} \
    ${data_test_dir} \
    "exp/triphones/decode_test_dir" \
    || (printf "\n####\n#### ERROR: decode.sh \n####\n\n" && exit 1);

# if using big_lm decoder
#steps/decode_biglm.sh --nj ${num_processors} \
#    ${graph_dir} \
#    #add old LM here \
#    #add new LM here \
#    ${data_test_dir} \
#    "exp/triphones/decode_test_dir" \
#    || printf "\n####\n#### ERROR: decode.sh \n####\n\n";

#Print timestamp in HH:MM:SS (24 hour format)
printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"

# outputs transcript
for x in exp/triphones/decode_test_dir/scoring/${weight}.tra; do
    utils/int2sym.pl -f 2- exp/triphones/graph/words.txt ${x} \
        || (printf "\n####\n#### ERROR: int2sym.pl\n####\n\n" && exit 1);
done
echo

# calculates *best* WER (from three runs)
for x in exp/*/decode*; do
    [ -d ${x} ] && grep WER ${x}/wer_* | utils/best_wer.sh \
        || (printf "\n####\n#### ERROR: best_wer.sh\n####\n\n" && exit 1);
done