#!/usr/bin/env bash

#will run goVivace client over a folder structure of audio and ONE transcript file and evaluate WER for each

# $1 = location of results
# $2 = location of audio
# $3 = filetype for audio (e.g. ".wav")
# $4 = location of gold transcript file
# $5 = location of goVivace transcripts (using prepareTranscript.pl)
            #[same as audio].goV

results=$1
audio_dir=$2
audio_type=$3
gold_file=$4
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

#write each utterance ID to golds.list
while IFS=$' ' read -r ID; do       #pay attention only to the ID
    echo ${ID} >> ${tmpFolder}golds.list
done < $gold_file


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

        #make a file of only that utterance ID (.gold)
        #TODO find that line only and write to file

        echo "Writing results to file"
        #prepare results file
        echo "============" >> $results
        echo $filename >> $results
        #send resulting .goV transcript and .gold transcript to compute-wer.cc
        ../src/bin/compute-wer --text --mode=present ark:${gold_dir}${filename}.gold ark:${goV_dir}${filename}.goV >> $results

        #TODO delete .gold file

    done < ${tmpFolder}common.list

else

    #TODO update to handle one .golds file

    #iterate through commons.list
    while read filename
    do
        echo "Writing results to file"
        #prepare results file
        echo "============" >> $results
        echo $filename >> $results
        #send resulting .goV transcript and .gold transcript to compute-wer.cc
        ../src/bin/compute-wer --text --mode=present ark:${gold_dir}${filename}.gold ark:${goV_dir}${filename}.goV >> $results

    done < ${tmpFolder}common.list

fi


#cleaning up temp files
rm -r $tmpFolder



