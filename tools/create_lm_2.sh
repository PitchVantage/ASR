#!/bin/bash

input=$1
output=$2

export IRSTLM=/Volumes/poo/ASR/tools/extras/irstlm
export PATH=${PATH}:${IRSTLM}/bin


build-lm.sh -i $1 -n 3 -o train.ilm.gz -k 5

compile-lm --text=yes train.ilm.gz $output

rm train.ilm.gz
