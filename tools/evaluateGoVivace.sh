#!/usr/bin/env bash

#will run goVivace client over a folder structure and evaluate WER for each

# $1 = location of results
# $2 = location of audio
# $3 = filetype for audio (e.g. ".wav")
# $4 = location of gold transcripts (using prepareTranscript.pl)
            #[same as audio].gold
# $5 = location of goVivace transcripts (using prepareTranscript.pl)
            #[same as audio].goV

results=$1
audio_dir=$2
audio_type=$3
gold_dir=$4
if [ -z $5 ]; then
    :
else
    goV_dir=$5
fi

#get a list of all audio, sorted
ALLAUDIO=( $(find $2 -name *$3 -type f | sort --version-sort) )

#get a list of all transcripts, sorted
ALLGOLD=( $(find $4 -name *.gold -type f | sort --version-sort) )




