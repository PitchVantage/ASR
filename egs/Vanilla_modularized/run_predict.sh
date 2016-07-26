#!/usr/bin/env bash

# This script will house the steps for predicting a *single* transcription from a *single* novel
# audio.

# TODO data needs to be in `nextiva_recipes/data/test_dir`
# TODO must still run run_prepare_data.sh and run_feature_extraction (with `-t` flags only) and
# TODO then run `decode.sh` with `--skip_scoring=true`