#!/usr/bin/env bash

# This script removes all files generated in `nextiva_recipes` after any step of the process.
# Ensures a clean state

rm -rf ${PATH_TO_KALDI}/egs/nextiva_recipes/data/ \
    ${PATH_TO_KALDI}/egs/nextiva_recipes/mfcc/ \
    ${PATH_TO_KALDI}/egs/nextiva_recipes/exp/

