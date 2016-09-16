#!/usr/bin/env bash

# This script creates a fully expanded decoding graph (HCLG) that represents
# the language-model, pronunciation dictionary (lexicon), context-dependency,
# and HMM structure in our model.  The output is a Finite State Transducer
# that has word-ids on the output, and pdf-ids on the input (these are indexes
# that resolve to Gaussian Mixture Models).


printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"

utils/mkgraph.sh \
    data/lang_test_tg \
    exp/triphones \
    exp/triphones/graph \
    || (printf "\n####\n#### ERROR: mkgraph.sh \n####\n\n" && exit 1);

printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"