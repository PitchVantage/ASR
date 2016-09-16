#!/usr/bin/env bash

# This script creates a fully expanded decoding graph (HCLG) that represents
# the language-model, pronunciation dictionary (lexicon), context-dependency,
# and HMM structure in our model.  The output is a Finite State Transducer
# that has word-ids on the output, and pdf-ids on the input (these are indexes
# that resolve to Gaussian Mixture Models).

# REQUIRE ARGUMENT
# -t <path> = full path to folder containing phones to use, default=`exp/triphones/`

# OPTIONAL ARGUMENTS
# -g <path> = full path to copy output `graph`
# -l <path> = full path to copy output lexicon lookup
# -o <path> = full path to copy output `.mdl`
# -i <path> = full path to copy output index lexicon
# -q <string> = non-vanilla hyperparameters to `mkgraph.sh`, in the form "--self-loop-scale .4"


# OUTPUTS
# Creates `exp/triphones/graph` subdirectory and `data/lang_test_tg/tmp/` for housing files
# related to the building of the graph
# *NOTE*: The following files are the only ones required for `run_predict.sh`:
# (1) `exp/triphones/graph/HCLG.fst`
# (2) `exp/triphones/graph/words.txt`
# (3) `exp/triphones/final.mdl`
# (4) `data/lang/phones/align_lexicon.int`
# If the optional arguments are used, the following files will be saved
# to a secondary location.  These files are needed for `run_predict.sh`

#default variables
phones=${PATH_TO_KALDI}/egs/nextiva_recipes/exp/triphones/
graph=
words=
model=
hyperparameters=

while getopts "t:g:l:o:i:q:" opt; do
    case ${opt} in
        t)
            phones=${OPTARG}/
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
        i)
            words_align=${OPTARG}
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

printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"

${PATH_TO_KALDI}/egs/nextiva_recipes/utils/mkgraph.sh \
    ${hyperparameters} \
    ${PATH_TO_KALDI}/egs/nextiva_recipes/data/lang_test_tg \
    ${phones} \
    ${PATH_TO_KALDI}/egs/nextiva_recipes/exp/triphones/graph \
    || (printf "\n####\n#### ERROR: mkgraph.sh \n####\n\n" && exit 1);


printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"

# copy files if optional arguments were set
if [ ! -z "${graph}" ]; then
    echo "copying graph to ${graph}"
    cp ${PATH_TO_KALDI}/egs/nextiva_recipes/exp/triphones/graph/HCLG.fst ${graph} \
        || (printf "\n####\n#### ERROR: copying file to ${graph}\n####\n\n" && exit 1);
fi

if [ ! -z "${words}" ];  then
    echo "copying lexicon lookup to ${words}"
    cp ${PATH_TO_KALDI}/egs/nextiva_recipes/exp/triphones/graph/words.txt ${words} \
        || (printf "\n####\n#### ERROR: copying file to ${words}\n####\n\n" && exit 1);
fi

if [ ! -z "${model}" ]; then
    echo "copying model to ${model}"
    cp -L ${phones}final.mdl ${model} \
        || (printf "\n####\n#### ERROR: copying file to ${model}\n####\n\n" && exit 1);
fi

if [ ! -z "${words_align}" ]; then
    echo "copying indexed lexicon to ${words_align}"
    cp -L ${PATH_TO_KALDI}/egs/nextiva_recipes/data/lang/phones/align_lexicon.int ${words_align} \
        || (printf "\n####\n#### ERROR: copying file to ${words_align}\n####\n\n" && exit 1);
fi