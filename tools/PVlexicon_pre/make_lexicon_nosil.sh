#!/usr/bin/env bash

# This script creates a `lexicon_nosil` from a `lexicon`

# $1 = full path to existing `lexicon`
# $2 = full path to output `lexicon_nosil`

cat $1 | grep -v -e \<SIL -e \<sil -e \<UNK -e \<unk > $2
