#!/usr/bin/env bash

# This script uses `irstlm` to build a language model in the `ARPA` format

# -m <string> = full path to irstlm installed
# -i <string> = list of paths to multiple `.txt` files to use in building language model
# use " " to make a list of files
# -o <string> = full path to output of new language model
# -s <no argument> = add <s> and </s>?
# -c <no argument> = compress final model?
# -n <int> = size of n-gram to build in language model, default=3
# -k <int> = number of splits to make in training process, default=5

# default values
prune=false
segment=false
compress=false
n=3
k=5

while getopts "m:i:o:scn:k:" opt; do
    case ${opt} in
        m)
            export IRSTLM=${OPTARG}
            export PATH=${PATH}:${IRSTLM}/bin
            ;;
        i)
            files_in=(${OPTARG})
            ;;
        o)
            file_out=${OPTARG}
            ;;
        s)
            segment=true
            ;;
        c)
            compress=true
            ;;
        n)
            n=${OPTARG}
            ;;
        k)
            k=${OPTARG}
            ;;
        \?)
            echo "Please use correct flags"
            exit 1
            ;;
    esac
done

# make temp folder
mkdir -p /tmp/kaldi_lm

# concatenate files to be used in model
for f in "${files_in[@]}"; do
    (cat ${f}; echo)
done > /tmp/kaldi_lm/concat.txt

if [ "${segment}" = true ]; then
    # add <s> and </s>
    add-start-end.sh < /tmp/kaldi_lm/concat.txt > /tmp/kaldi_lm/concat_start_stop.txt
    # build
    build-lm.sh -i /tmp/kaldi_lm/concat_start_stop.txt -o /tmp/kaldi_lm/train.ilm.gz -n ${n} -k ${k}
else
    # build
    build-lm.sh -i /tmp/kaldi_lm/concat.txt -o /tmp/kaldi_lm/train.ilm.gz -n ${n} -k ${k}
fi

if [ "${compress}" = true ]; then
    # compile and compress
    compile-lm /tmp/kaldi_lm/train.ilm.gz --text=yes /dev/stdout | gzip -c > ${file_out}.gz
else
    # compile
    compile-lm --text=yes /tmp/kaldi_lm/train.ilm.gz ${file_out}
fi

# remove tmp files
rm -rf /tmp/kaldi_lm/

