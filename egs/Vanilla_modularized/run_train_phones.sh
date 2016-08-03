#!/usr/bin/env bash

# This script trains `monophone`s and `triphone`s for given `mfcc`s
# Creates `exp/monophones/`, `exp/monophones_aligned/` and `exp/triphones/`

# -j <int> = number of processors to use, default=2
# -l <int> = number of leaves, default=2000
# -g <int> = total number of Gaussians, default=10000

# default values for variables
num_processors=2
num_leaves=2000
tot_gaussian=10000

while getopts "j:l:g:" opt; do
    case ${opt} in
        j)
            # update number of processors used
            num_processors=${OPTARG}
            ;;
        l)
            # update number of leaves
            num_leaves=${OPTARG}
            ;;
        g)
            # update total Gaussians
            tot_gaussian=${OPTARG}
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

# Flat start and monophone training, with delta-delta features
# This script applies cepstral mean normalization (per speaker)
# TODO why don't we do anything with data/test_dir????

# removed --cmd and --totgauss options in original `run`, sticking with default
steps/train_mono.sh --nj ${num_processors} \
    data/train_dir \
    data/lang \
    exp/monophones \
    || (printf "\n####\n#### ERROR: train_mono.sh \n####\n\n" && exit 1);

printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"

# Align monophones with data
# Computes training alignments using a model with delta or LDA+MLLT features.

# removed --boost_silence=1.25 option in original `run`, sticking with default
steps/align_si.sh --nj ${num_processors} \
    data/train_dir \
    data/lang \
    exp/monophones \
    exp/monophones_aligned \
    || (printf "\n####\n#### ERROR: align_si.sh \n####\n\n" && exit 1);

printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"

# Train tri1, which is deltas + delta-deltas, on train data.

# removed --cmd in original `run`, sticking with default
steps/train_deltas.sh \
    ${num_leaves} \
    ${tot_gaussian} \
    data/train_dir \
    data/lang \
    exp/monophones_aligned \
    exp/triphones \
    || (printf "\n####\n#### ERROR: train_deltas.sh \n####\n\n" && exit 1);

printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"