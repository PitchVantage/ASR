#!/usr/bin/env bash

#compares WER results between a Kaldi system and GoVivace
#must be run from tools/

#TODO parallelize: http://stackoverflow.com/questions/38160/parallelize-bash-script-with-maximum-number-of-processes

# $1 = location to save results
# $2 = location of cleaned (using prepareTranscript.pl) gold transcripts
            #[same name as wav].gold
# $3 = location of cleaned (using prepareTranscript.pl??) kaldi transcripts
            #[same name as wav].kaldi
            #TODO check that prepareTranscript.pl is needed
# $4 = location of cleaned (using prepareTranscript.pl) GoVivace transcripts
            #[same name as wav].goV
# $5 = optional: location of wav files to test



results=$1
gold_dir=$2
kaldiTranscripts_dir=$3
goVivaceTranscripts_dir=$4
#assignment of this variable depends on whether $4 is empty or not
if [ "$(ls -A $4)" ]; then
	requireTranscribe=false
else
	requireTranscribe=true
fi
#assignment of this variable depends on whether $5 exists or not
if [ -z $5 ]; then
    :               #do nothing
else
    waves_dir=$5    #assign variable
fi

echo "Cataloging files"

#TODO is this cataloging necessary?
#print all filenames in $gold_dir to file
ls -1 $gold_dir > goldTranscripts_all.list

#print all filenames in $kaldiTranscripts_dir to file
ls -1 $kaldiTranscripts_dir > predictKaldiTranscripts_all.list

####################################################################

#if goVivace transcription has already occurred
# print all filenames to file
if [ $requireTranscribe == false ]; then
    #print all filenames in $goVivaceTrnascripts_dir to file
    ls -1 $goVivaceTranscripts_dir > predictGoVivaceTranscripts_all.list

    #sort files by bytes (kaldi-style) and resave
    for fileName in goldTranscripts_all.list predictKaldiTranscripts_all.list predictGoVivaceTranscrips_all.list; do
        LC_ALL=C sort -i $fileName -o $fileName;
    done

    #TODO ensure all files that are needed exist

    #iterate through all files in list and run .compute-wer
    for fileName in goldTranscripts_all.list; do
        #get basename
        base=$(basename $fileName)
        #match file without extension
        [[ $base =~ (.*)\..* ]]
        fileNoExt="${BASH_REMATCH[1]}"
        #build filenames
        gold=$gold_dir$fileNoExt.gold
        kaldi=$kaldiTranscripts_dir$fileNoExt.kaldi
        goV=$goVivaceTranscripts_dir$fileNoExt.goV
        #prepare results file
        echo "=======" >> ${results}
        echo $base - "Kaldi:" >> ${results}
        #run compute-wer.c on kaldi
        ../src/bin/compute-wer --text --mode=present ark:$gold ark:$kaldi >> $results
        #prepare results file
        echo $base - "GoVivace:" >> ${results}
        #run compute-wer.c on goVivace
        ../src/bin/compute-wer --text --mode=present ark:$gold ark:$goV >> $results
    done

#if goVivace transcriptions haven't already been created
else
    #print all filenames in $waves_dir to file
    ls -1 $waves_dir > waves_all.list

    #sort files by bytes (kaldi-style) and resave
    for fileName in waves_all.list; do
        LC_ALL=C sort -i $fileName -o $fileName;
    done

    #iterate through wave files
    for fileName in waves_all.list; do
        #get basename
        base=$(basename $fileName)
        #match file without extension
        [[ $base =~ (.*)\..* ]]
        fileNoExt="${BASH_REMATCH[1]}"
        #build filenames
        gold=$gold_dir$base.gold
        kaldi=$kaldiTranscripts_dir$fileNoExt.kaldi
        raw=$goVivaceTranscripts_dir$fileNoExt.raw
        goV=$goVivaceTranscripts_dir$fileNoExt.goV
        #call goVivace client
            #name file .raw
        ./callGoVivace.sh text $fileName $raw
        #clean raw transcript
            #[same name as wav].goV
        ./prepareTranscript.pl $raw $goV
        #delete raw file
        rm $raw
        #prepare results file
        echo $base >> ${results}
        echo "=======" >> ${results}
        echo "Kaldi:" >> ${results}
        #run compute-wer.c on kaldi
        ../src/bin/compute-wer --text --mode=present ark:$gold ark:$kaldi >> $results
        #prepare results file
        echo "=======" >> ${results}
        echo "GoVivace:" >> ${results}
        #run compute-wer.c on goVivace
        ../src/bin/compute-wer --text --mode=present ark:$gold ark:$goV >> $results
    done
fi



