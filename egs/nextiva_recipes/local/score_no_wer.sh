#!/usr/bin/env bash
# Copyright 2012  Johns Hopkins University (Author: Daniel Povey)
# Apache 2.0

# modified from `score.sh` so as not to compute `WER`

[ -f ${PATH_TO_KALDI}/egs/nextiva_recipes/path.sh ] && . ${PATH_TO_KALDI}/egs/nextiva_recipes/path.sh

# begin configuration section.
cmd=run.pl
stage=0
decode_mbr=true
reverse=false
word_ins_penalty=0.0
min_lmwt=9
max_lmwt=11
words=${PATH_TO_KALDI}/egs/nextiva_recipes/exp/triphones/graph/words.txt
words_align=${PATH_TO_KALDI}/egs/nextiva_recipes/data/lang/phones/align_lexicon.int
model=${PATH_TO_KALDI}/egs/nextiva_recipes/exp/triphones/final.mdl
temp=/tmp/kaldi_decode
#end configuration section.

[ -f ./path.sh ] && . ./path.sh
. parse_options.sh || exit 1;

if [ $# -ne 2 ]; then
  echo "Usage: local/score_no_wer.sh <temp-dir> <decode-dir>"
  echo " Options:"
  echo "    --cmd (run.pl|queue.pl...)      # specify how to run the sub-processes."
  echo "    --stage (0|1|2)                 # start scoring script from part-way through."
  echo "    --decode_mbr (true/false)       # maximum bayes risk decoding (confusion network)."
  echo "    --min_lmwt <int>                # minumum LM-weight for lattice rescoring "
  echo "    --max_lmwt <int>                # maximum LM-weight for lattice rescoring "
  echo "    --reverse (true/false)          # score with time reversed features "
  exit 1;
fi

temp=$1
data=${temp}data
dir=$2

mkdir -p ${dir}/scoring/log

#cat $data/text | sed 's:<NOISE>::g' | sed 's:<SPOKEN_NOISE>::g' > $dir/scoring/test_filt.txt

$cmd LMWT=$min_lmwt:$max_lmwt $dir/scoring/log/best_path.LMWT.log \
  lattice-scale --inv-acoustic-scale=LMWT "ark:gunzip -c $dir/lat.*.gz|" ark:- \| \
  lattice-add-penalty --word-ins-penalty=$word_ins_penalty ark:- ark:- \| \
  lattice-best-path --word-symbol-table=$symtab \
    ark:- ark,t:$dir/scoring/LMWT.tra || exit 1;

if $reverse; then
  for lmwt in `seq $min_lmwt $max_lmwt`; do
    mv $dir/scoring/$lmwt.tra $dir/scoring/$lmwt.tra.orig
    awk '{ printf("%s ",$1); for(i=NF; i>1; i--){ printf("%s ",$i); } printf("\n"); }' \
       <$dir/scoring/$lmwt.tra.orig >$dir/scoring/$lmwt.tra
  done
fi


# outputs transcript
${PATH_TO_KALDI}/egs/nextiva_recipes/utils/int2sym.pl -f 2- ${words} ${dir}scoring/*.tra

# TODO parameterize acoustic scale?

# generates utterance confidence
# this is *not* a percentage, it is the difference in cost between best path and second-best path
# averaged in negative-log space
lattice-confidence --acoustic-scale=0.1 "ark:gunzip -c ${dir}lat.*.gz|" ark,t:-

# aligns the words in preparation for timestamps and confidences
lattice-align-words-lexicon \
    ${words_align} \
    ${model} \
    "ark:gunzip -c ${dir}lat.*.gz|" \
    ark:${dir}aligned_lat.lat

# generate timestamps and word confidences
lattice-mbr-decode \
    --acoustic-scale=0.1 \
    ark:${dir}aligned_lat.lat \
    ark:${dir}scoring/*.tra \
    ark:/dev/null \
    ark,t:${dir}sausage.sau \
    ark,t:${dir}timestamps.ts




exit 0;
