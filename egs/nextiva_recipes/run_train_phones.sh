#!/usr/bin/env bash

# This script trains `monophone`s and `triphone`s for given `mfcc`s

#ARGUMENTS
## REQUIRED
# -i <string> = type of phone training to do: "delta", "delta_delta", "lda_mllt", or "sat"

## OPTIONAL
# -j <int> = number of processors to use, default=2
# -l <int> = number of leaves, default=2000
# -g <int> = total number of Gaussians, default=10000
# -p <int> = rate to reduce original audio file size to speed up `train_mono.sh`, example `-p 4` = use 1/4 original files
# -q <string> = non-vanilla hyperparameters to `train_mono.sh`, in the form "--num_iters 50"
# -r <string> = non-vanilla hyperparameters to `align_si.sh` for monophones, in the form "--beam 20"
# -s <string> = non-vanilla hyperparameters to `train_deltas.sh` of deltas, in the form "--num_iters 50"
# -t <string> = non-vanilla hyperparameters to `align_si.sh` for deltas, in the form "--beam 20"
# -u <string> = non-vanilla hyperparameters to `train_deltas.sh` of delta-deltas, in the form "--num_iters 50"
# -v <string> = non-vanilla hyperparameters to `align_si.sh` for delta-deltas, in the form "--beam 20"
# -w <string> = non-vanilla hyperparameters to `train_lda_mllt.sh` for LDA-MLLT, in the form "--beam 20"
# -x <string> = non-vanilla hyperparameters to `align_fmllr.sh` for LDA-MLLT, in the form "--beam 20"
# -y <string> = non-vanilla hyperparameters to `train_sat.sh` for SAT, in the form "--beam 20"
# -z <string> = non-vanilla hyperparameters to `align_fmllr.sh` for SAT, in the form "--beam 20"

# OUTPUTS
# Creates `exp/monophones/`, `exp/monophones_aligned/` and `exp/triphones/` and `exp/triphones_aligned/`
# and, depending on training type, `exp/{triphones_2, triphones_2_aligned, triphones_lda, triphones_lda_aligned, triphones_sat, and triphones_sat_aligned}
# subdirectories for trained phones and logs

# default values for variables
num_processors=2
num_leaves=2000
tot_gaussian=10000
reduce_n=
mono_hyperparameters=
mono_align_hyperparameters=
delta_hyperparameters=
delta_align_hyperparameters=
delta_delta_hyperparameters=
delta_delta_align_hyperparameters=
lda_hyperparameters=
lda_align_hyperparameters=
sat_hyperparameters=
sat_align_hyperparameters=


while getopts "i:j:l:g:p:q:r:s:t:u:v:w:x:y:z:" opt; do
    case ${opt} in
        i)
            training_type=${OPTARG}
            ;;
        j)
            num_processors=${OPTARG}
            ;;
        l)
            num_leaves=${OPTARG}
            ;;
        g)
            tot_gaussian=${OPTARG}
            ;;
        p)
            reduce_rate=${OPTARG}
            total_files=$(cat ${PATH_TO_KALDI}/egs/nextiva_recipes/data/train_dir/utt2spk | wc -l)
            reduce_n=$(expr ${total_files} \/ ${reduce_rate})
            ;;
        q)
            mono_hyperparameters=${OPTARG}
            ;;
        r)
            mono_align_hyperparameters=${OPTARG}
            ;;
        s)
            delta_hyperparameters=${OPTARG}
            ;;
        t)
            delta_align_hyperparameters=${OPTARG}
            ;;
        u)
            delta_delta_hyperparameters=${OPTARG}
            ;;
        v)
            delta_delta_align_hyperparameters=${OPTARG}
            ;;
        w)
            lda_hyperparameters=${OPTARG}
            ;;
        x)
            lda_align_hyperparameters=${OPTARG}
            ;;
        y)
            sat_hyperparameters=${OPTARG}
            ;;
        z)
            sat_align_hyperparameters=${OPTARG}
            ;;
        \?)
            echo "Wrong flags"
            exit 1
            ;;
    esac
done

# determine type of training
if [ ${training_type} == "delta" ]; then
    echo "delta training"
elif [ ${training_type} == "delta_delta" ]; then
    echo "delta + delta-delta training"
elif [ ${training_type} == "lda_mllt" ]; then
    echo "LDA-MLLT training"
elif [ ${training_type} == "sat" ]; then
    echo "SAT training"
else
    echo "training type options:"
    echo "\"delta\" = delta-based triphones, aligned"
    echo "\"delta_delta\" = delta + delta-delta triphones, aligned"
    echo "\"lda_mllt\" = LDA-MLLT triphones aligned with FMLLR"
    echo "\"sat\" = SAT triphones aligned with FMLLR"
    exit 1
fi

printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"

# Flat start and monophone training
# This script applies cepstral mean normalization (per speaker)

if [ ! -z "${reduce_n}" ]; then

    # get sample of training audio
    ${PATH_TO_KALDI}/egs/nextiva_recipes/utils/subset_data_dir.sh \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/data/train_dir \
        ${reduce_n} \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/data/train_${reduce_n}_dir

    # removed --cmd in original `run`, sticking with default
    ${PATH_TO_KALDI}/egs/nextiva_recipes/steps/train_mono.sh \
        ${mono_hyperparameters} \
        --nj ${num_processors} \
        --totgauss ${tot_gaussian} \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/data/train_${reduce_n}_dir \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/data/lang \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/exp/monophones \
        || (printf "\n####\n#### ERROR: train_mono.sh \n####\n\n" && exit 1);

else

    # removed --cmd and --totgauss options in original `run`, sticking with default
    ${PATH_TO_KALDI}/egs/nextiva_recipes/steps/train_mono.sh \
        ${mono_hyperparameters} \
        --nj ${num_processors} \
        --totgauss ${tot_gaussian} \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/data/train_dir \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/data/lang \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/exp/monophones \
        || (printf "\n####\n#### ERROR: train_mono.sh \n####\n\n" && exit 1);

fi


printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"

# align monophones with data

# removed --boost_silence=1.25 option in original `run`, sticking with default
${PATH_TO_KALDI}/egs/nextiva_recipes/steps/align_si.sh \
    ${mono_align_hyperparameters} \
    --nj ${num_processors} \
    ${PATH_TO_KALDI}/egs/nextiva_recipes/data/train_dir \
    ${PATH_TO_KALDI}/egs/nextiva_recipes/data/lang \
    ${PATH_TO_KALDI}/egs/nextiva_recipes/exp/monophones \
    ${PATH_TO_KALDI}/egs/nextiva_recipes/exp/monophones_aligned \
    || (printf "\n####\n#### ERROR: align_si.sh of monophones\n####\n\n" && exit 1);

printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"

# train deltas
# removed --cmd in original `run`, sticking with default
${PATH_TO_KALDI}/egs/nextiva_recipes/steps/train_deltas.sh \
    ${delta_hyperparameters} \
    ${num_leaves} \
    ${tot_gaussian} \
    ${PATH_TO_KALDI}/egs/nextiva_recipes/data/train_dir \
    ${PATH_TO_KALDI}/egs/nextiva_recipes/data/lang \
    ${PATH_TO_KALDI}/egs/nextiva_recipes/exp/monophones_aligned \
    ${PATH_TO_KALDI}/egs/nextiva_recipes/exp/triphones \
    || (printf "\n####\n#### ERROR: train_deltas.sh \n####\n\n" && exit 1);

printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"

# align deltas
${PATH_TO_KALDI}/egs/nextiva_recipes/steps/align_si.sh \
    ${delta_align_hyperparameters} \
    --nj ${num_processors} \
    ${PATH_TO_KALDI}/egs/nextiva_recipes/data/train_dir \
    ${PATH_TO_KALDI}/egs/nextiva_recipes/data/lang \
    ${PATH_TO_KALDI}/egs/nextiva_recipes/exp/triphones \
    ${PATH_TO_KALDI}/egs/nextiva_recipes/exp/triphones_aligned \
    || (printf "\n####\n#### ERROR: align_si.sh of triphones \n####\n\n" && exit 1);

printf "Timestamp in HH:MM:SS (24 hour format)\n";
date +%T
printf "\n"

if [[ ${training_type} != "delta" ]]; then

    # set increased values for delta + delta-delta stage
    # 25% more than in delta stage
    tri_leaves=$(expr ${num_leaves} \/ 4 + ${num_leaves})
    # 50% more than in delta stage
    tri_gaussian=$(expr ${tot_gaussian} \/ 2 + ${tot_gaussian})

    # train delta + delta-deltas
    ${PATH_TO_KALDI}/egs/nextiva_recipes/steps/train_deltas.sh \
        ${delta_delta_hyperparameters} \
        ${tri_leaves} \
        ${tri_gaussian} \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/data/train_dir \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/data/lang \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/exp/triphones_aligned \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/exp/triphones_2 \
        || (printf "\n####\n#### ERROR: train_deltas.sh \n####\n\n" && exit 1);

    printf "Timestamp in HH:MM:SS (24 hour format)\n";
    date +%T
    printf "\n"

    # align delta + delta-deltas
    ${PATH_TO_KALDI}/egs/nextiva_recipes/steps/align_si.sh \
        ${delta_delta_align_hyperparameters} \
        --nj ${num_processors} \
        --use-graphs true \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/data/train_dir \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/data/lang \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/exp/triphones_2 \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/exp/triphones_2_aligned \
        || (printf "\n####\n#### ERROR: align_si.sh of triphones \n####\n\n" && exit 1);

    printf "Timestamp in HH:MM:SS (24 hour format)\n";
    date +%T
    printf "\n"

fi

if [[ ${training_type} != "delta" ]] && [[ ${training_type} != "delta_delta" ]]; then

    # set increased values for LDA-MLLT stage
    # 33% more than in delta-delta stage
    lda_leaves=$(expr ${tri_leaves} \/ 3 + ${tri_leaves})
    # 33% more than in delta-delta stage
    lda_gaussian=$(expr ${tri_gaussian} \/ 3 + ${tri_gaussian})

    # train LDA-MLLT
    ${PATH_TO_KALDI}/egs/nextiva_recipes/steps/train_lda_mllt.sh \
        ${lda_hyperparameters} \
        ${lda_leaves} \
        ${lda_gaussian} \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/data/train_dir \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/data/lang \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/exp/triphones_2_aligned \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/exp/triphones_lda \
        || (printf "\n####\n#### ERROR: train_lda_mllt.sh \n####\n\n" && exit 1);

    printf "Timestamp in HH:MM:SS (24 hour format)\n";
    date +%T
    printf "\n"

    # align with FMLLR
    ${PATH_TO_KALDI}/egs/nextiva_recipes/steps/align_fmllr.sh \
        ${lda_align_hyperparameters} \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/data/train_dir \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/data/lang \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/exp/triphones_lda \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/exp/triphones_lda_aligned \
        || (printf "\n####\n#### ERROR: train_lda_mllt.sh \n####\n\n" && exit 1);

    printf "Timestamp in HH:MM:SS (24 hour format)\n";
    date +%T
    printf "\n"

fi

if [ ${training_type} == "sat" ]; then

    # set increased values for SAT stage
    # 20% more than LDA-MLLT stage
    sat_leaves=$(expr ${lda_leaves} \/ 5 + ${lda_leaves})
    # 100% more than LDA-MLLT stage
    sat_gaussian=$(expr ${lda_leaves} + ${lda_leaves})

    # train SAT
    ${PATH_TO_KALDI}/egs/nextiva_recipes/steps/train_sat.sh \
        ${sat_align_hyperparameters} \
        ${sat_leaves} \
        ${sat_gaussian} \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/data/train_dir \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/data/lang \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/exp/triphones_lda_aligned \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/exp/triphones_sat \
        || (printf "\n####\n#### ERROR: train_lda_mllt.sh \n####\n\n" && exit 1);

    # align with FMLLR
    ${PATH_TO_KALDI}/egs/nextiva_recipes/steps/align_fmllr.sh \
        ${sat_align_hyperparameters} \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/data/train_dir \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/data/lang \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/exp/triphones_sat \
        ${PATH_TO_KALDI}/egs/nextiva_recipes/exp/triphones_sat_aligned \
        || (printf "\n####\n#### ERROR: train_lda_mllt.sh \n####\n\n" && exit 1);

    printf "Timestamp in HH:MM:SS (24 hour format)\n";
    date +%T
    printf "\n"

fi