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
goV_dir=$5

tmpFolder=/tmp/kaldiEvaluate/

mkdir $tmpFolder
#touch $results

echo "Checking audio files"

#get a list of all audio, sorted, and write to list file
ALLAUDIO=( $(find $2 -name *$3 -type f | sort --version-sort) )
for i in ${ALLAUDIO[@]}; do
    #get basename
    base=$(basename $i)
    #match file without extension
    [[ $base =~ (.*)\..* ]]
    fileNoExt="${BASH_REMATCH[1]}"
    #write to list
    echo $fileNoExt >> ${tmpFolder}waves.list
done

echo "Checking gold transcript files"

#get a list of all gold transcripts, sorted, and write to list file
ALLGOLD=( $(find $4 -name *.gold -type f | sort --version-sort) )
for j in ${ALLGOLD[@]}; do
    #get basename
    base=$(basename $j)
    #match file without extension
    [[ $base =~ (.*)\..* ]]
    fileNoExt="${BASH_REMATCH[1]}"
    #write to list
    echo $fileNoExt >> ${tmpFolder}golds.list
done

echo "Building list of files to evaluate"

#get list of files for which both gold transcript and wave exist
comm -12 ${tmpFolder}waves.list ${tmpFolder}golds.list >> ${tmpFolder}common.list


#if .goV transcripts don't yet exist
if [ ! -d "$goV_dir" ]; then

    #make directory for .goV
    mkdir $goV_dir

    #iterate through commons.list
    while read filename
    do

        echo "Calling GoVivace client"
        #send to goVivace client
        ./callGoVivace.sh text ${audio_dir}${filename}.wav ${goV_dir}${filename}.raw

        #clean transcript for WER comparison
        ./prepareTranscript.pl ${goV_dir}$filename.raw ${goV_dir}$filename.goV

        #remove .raw file, keeping only cleaned .goV
        rm ${goV_dir}$filename.raw

        echo "Writing results to file"
        #prepare results file
        echo $filename >> $results
        #send resulting .goV transcript and .gold transcript to compute-wer.cc
        ../src/bin/compute-wer --text --mode=present ark:${gold_dir}${filename}.gold ark:${goV_dir}${filename}.goV >> $results
        echo "============" >> $results
    done < ${tmpFolder}common.list

else

    #iterate through commons.list
    while read filename
    do
        echo "Writing results to file"
        #prepare results file
        echo $filename >> $results
        #send resulting .goV transcript and .gold transcript to compute-wer.cc
        ../src/bin/compute-wer --text --mode=present ark:${gold_dir}${filename}.gold ark:${goV_dir}${filename}.goV >> $results
        echo "============" >> $results
    done < ${tmpFolder}common.list

fi


#cleaning up temp files
rm -r $tmpFolder



