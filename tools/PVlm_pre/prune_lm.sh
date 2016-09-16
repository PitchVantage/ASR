#!/usr/bin/env bash

# This script prunes an existing language model by removing n-grams
# for which resorting to the back-off results in a small loss

# -m <string> = full path to irstlm installed
# -i <string> = full path to existing language model
# -o <string> = full path to output of new language model
# -p <string> = threshold for pruning, default="1e-6"
# -c <no argument> = compress final model?

# default values
compress=false
threshold=1e-6

while getopts "m:i:o:p:c" opt; do
    case ${opt} in
        m)
            export IRSTLM=${OPTARG}
            export PATH=${PATH}:${IRSTLM}/bin
            ;;
        i)
            file_in=${OPTARG}
            ;;
        o)
            file_out=${OPTARG}
            ;;
        p)
            threshold=${OPTARG}
            ;;
        c)
            compress=true
            ;;
        \?)
            echo "Please use correct flags"
            exit 1
            ;;
    esac
done

if [ "${compress}" = true ]; then
    prune-lm --threshold=${threshold},${threshold} ${file_in} /dev/stdout | gzip -c > ${file_out}.gz
else
    prune-lm --threshold=${threshold},${threshold} ${file_in} ${file_out}
fi
