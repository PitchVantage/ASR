#!/usr/bin/env bash

# Will prune a language model by removing n-grams for which resorting to the back-off results in a small loss.

# e.g

#$1 = unpruned language model (in)
#$2 = pruned language model (out)

export IRSTLM=/data/Github/ASR/tools/extras/irstlm
export PATH=${PATH}:${IRSTLM}/bin

prune-lm --threshold=1e-6,1e-6 $1 $2
