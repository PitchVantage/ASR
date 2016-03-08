#!/usr/bin/env bash

#compares WER results between a Kaldi system and GoVivace
#must be run from tools/
#TODO parallelize: http://stackoverflow.com/questions/38160/parallelize-bash-script-with-maximum-number-of-processes

# $1 = location of wav files to test
# $2 = location to save results
# $3 = location of cleaned (using prepareTranscript.pl) gold transcripts
            #[same name as wav].gold
# $4 = location of cleaned (using prepareTranscript.pl??) kaldi transcripts
            #[same name as wav].kaldi
            #TODO check that prepareTranscript.pl is needed
# $5 = location of cleaned (using prepareTranscript.pl) GoVivace transcripts
            #[same name as wav].goV


waves_dir=$1
results=$2
gold_dir=$3
kaldiTranscripts_dir=$4
goVivaceTranscripts_dir=$5
#assignment of this variable depends on whether $5 is empty or not
if [ "$(ls -A $5)" ]; then
	requireTranscribe=false
else
	requireTranscribe=true
fi

echo "Cataloging files"

#TODO is this cataloging necessary?
#print all filenames in $waves_dir to file
ls -1 $waves_dir > waves_all.list

#print all filenames in $gold_dir to file
ls -1 $gold_dir > goldTranscripts_all.list

#print all filenames in $kaldiTranscripts_dir to file
ls -1 $kaldiTranscripts_dir > predictKaldiTranscripts_all.list

####################################################################

#if goVivace transcription has already occurred
# print all filenames to file
if [ $requireTranscribe == false ]; then
    ls -1 $goVivaceTranscripts_dir > predictGoVivaceTranscripts_all.list

    #sort files by bytes (kaldi-style) and resave
    for fileName in goldTranscripts_all.list predictKaldiTranscripts_all.list predictGoVivaceTranscrips_all.list; do
        LC_ALL=C sort -i $fileName -o $fileName;
    done

    #TODO ensure all files that are needed exist

    #TODO iterate through all files in list and run .compute-wer
    for fileName in goldTranscripts_all.list; do
        #get basename
        base=$(basename $fileName)
        #build filenames
        gold=$base.gold
        kaldi=$base.kaldi
        goV=$base.goV
        #prepare results file
        echo $base >> ${results}
        echo "=======" >> ${results}
        echo "Kaldi:" >> ${results}
        #run compute-wer.c on kaldi
        ../src/bin/compute-wer --text --mode=present ark:${gold} ark:${kaldi} >> ${results}
        #prepare results file
        echo "=======" >> ${results}
        echo "GoVivace:" >> ${results}
        #run compute-wer.c on goVivace
        ../src/bin/compute-wer --text --mode=present ark:${gold} ark:${goV} >> ${results}
    done


#if goVivace transcriptions haven't already been created
else
    #TODO callGoVivace
        #[same name as wav].goV
    #TODO call compute-wer
fi



