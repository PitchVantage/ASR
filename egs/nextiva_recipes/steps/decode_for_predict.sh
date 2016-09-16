#!/usr/bin/env bash

# Copyright 2012  Johns Hopkins University (Author: Daniel Povey)
# Apache 2.0

# modified from steps/decode.sh to be used in prediction

# Begin configuration section.
transform_dir=   # this option won't normally be used, but it can be used if you want to
                 # supply existing fMLLR transforms when decoding.
num_threads=2 # if >1, will use gmm-latgen-faster-parallel
iter=
model=${PATH_TO_KALDI}/egs/nextiva_recipes/exp/triphones/final.mdl
graph=${PATH_TO_KALDI}/egs/nextiva_recipes/exp/triphones/graph/HCLG.fst
words=${PATH_TO_KALDI}/egs/nextiva_recipes/exp/triphones/graph/words.txt
nj=1
cmd=run.pl
max_active=7000
beam=13.0
lattice_beam=6.0
acwt=0.083333 # note: only really affects pruning (scoring is on lattices).
scoring_opts=
# note: there are no more min-lmwt and max-lmwt options, instead use
# e.g. --scoring-opts "--min-lmwt 1 --max-lmwt 20"
# End configuration section.

echo "$0 $@"  # Print the command line for logging

[ -f ${PATH_TO_KALDI}/egs/nextiva_recipes/path.sh ] && . ${PATH_TO_KALDI}/egs/nextiva_recipes/path.sh; # source the path.
. ${PATH_TO_KALDI}/egs/nextiva_recipes/utils/parse_options.sh || exit 1;

if [ $# != 2 ]; then
   echo "Usage: steps/decode_for_predict.sh [options] <data-dir> <decode-dir>"
   echo "... where <decode-dir> will contain output files from process."
   echo ""
   echo "This script works on CMN + (delta+delta-delta | LDA+MLLT) features; it works out"
   echo "what type of features you used (assuming it's one of these two)"
   echo ""
   echo "main options (for others, see top of script file)"
   echo "  --config <config-file>                           # config containing options"
   echo "  --nj <nj>                                        # number of parallel jobs"
   echo "  --iter <iter>                                    # Iteration of model to test."
   echo "  --model <model>                                  # which model to use (e.g. to"
   echo "                                                   # specify the final.alimdl)"
   echo "  --cmd (utils/run.pl|utils/queue.pl <queue opts>) # how to run jobs."
   echo "  --transform-dir <trans-dir>                      # dir to find fMLLR transforms "
   echo "  --acwt <float>                                   # acoustic scale used for lattice generation "
   echo "  --scoring-opts <string>                          # options to local/score.sh"
   echo "  --num-threads <n>                                # number of threads to use, default 1."
   echo "  --parallel-opts <opts>                           # ignored now, present for historical reasons."
   exit 1;
fi


data=$1
dir=$2
sdata=${data}/split${nj};

# splits data
# TODO figure out how to remove since we are only doing 1 at a time, but /1/ paths hardcoded
mkdir -p ${dir}/log
split_data.sh ${data} ${nj}

# generates argument for multiple threads
# TODO how is this different from `-nj`?
thread_string=
[ $num_threads -gt 1 ] && thread_string="-parallel --num-threads=$num_threads"

# ???
if [ $(basename $model) != final.alimdl ] ; then
  # Do not use the $srcpath -- look at the path where the model is
  if [ -f $(dirname ${model})/final.alimdl ] ; then
    echo -e '\n\n'
    echo $0 'WARNING: Running speaker independent system decoding using a SAT model!'
    echo $0 'WARNING: This is OK if you know what you are doing...'
    echo -e '\n\n'
  fi
fi

# looks for required files
# cmvn.scp
# .mdl
# HCLG.fst
for f in $sdata/1/feats.scp $sdata/1/cmvn.scp ${model} ${graph}; do
  [ ! -f $f ] && echo "decode_for_predict.sh: no such file $f" && exit 1;
done

# TODO add back in if need capacity for `lda`
# if `final.mat` exists, `lda` was run, if not, `delta` (???)
#if [ -f $srcdir/final.mat ]; then feat_type=lda; else feat_type=delta; fi
feat_type=delta


# get features
case ${feat_type} in
# if `delta` above
  delta) feats="ark,s,cs:apply-cmvn $cmvn_opts --utt2spk=ark:$sdata/JOB/utt2spk scp:$sdata/JOB/cmvn.scp scp:$sdata/JOB/feats.scp ark:- | add-deltas $delta_opts ark:- ark:- |";;
# if `lda` above
#  lda) feats="ark,s,cs:apply-cmvn $cmvn_opts --utt2spk=ark:$sdata/JOB/utt2spk scp:$sdata/JOB/cmvn.scp scp:$sdata/JOB/feats.scp ark:- | splice-feats $splice_opts ark:- ark:- | transform-feats $srcdir/final.mat ark:- ark:- |";;
  *) echo "Invalid feature type ${feat_type}" && exit 1;
esac

# transform features
# using transform-feats.cc
if [ ! -z "$transform_dir" ]; then # add transforms to features...
  echo "Using fMLLR transforms from $transform_dir"
  [ ! -f $transform_dir/trans.1 ] && echo "Expected $transform_dir/trans.1 to exist."
  [ ! -s $transform_dir/num_jobs ] && \
    echo "$0: expected $transform_dir/num_jobs to contain the number of jobs." && exit 1;
  nj_orig=$(cat $transform_dir/num_jobs)
  if [ $nj -ne $nj_orig ]; then
    # Copy the transforms into an archive with an index.
    echo "$0: num-jobs for transforms mismatches, so copying them."
    for n in $(seq $nj_orig); do cat $transform_dir/trans.$n; done | \
       copy-feats ark:- ark,scp:$dir/trans.ark,$dir/trans.scp || exit 1;
    feats="$feats transform-feats --utt2spk=ark:$sdata/JOB/utt2spk scp:$dir/trans.scp ark:- ark:- |"
  else
    # number of jobs matches with alignment dir.
    feats="$feats transform-feats --utt2spk=ark:$sdata/JOB/utt2spk ark:$transform_dir/trans.JOB ark:- ark:- |"
  fi
fi

# decode
# using gmm-latgen-faster.cc
$cmd --num-threads ${num_threads} JOB=1:${nj} ${dir}/log/decode.JOB.log \
    gmm-latgen-faster$thread_string --max-active=${max_active} --beam=${beam} --lattice-beam=${lattice_beam} \
    --acoustic-scale=${acwt} --allow-partial=true --word-symbol-table=${words} \
    ${model} ${graph} "${feats}" "ark:|gzip -c > ${dir}/lat.JOB.gz" || exit 1;

exit 0;
