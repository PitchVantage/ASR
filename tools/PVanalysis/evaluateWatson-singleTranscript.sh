#!/usr/bin/env bash

#will run Watson API over a folder structure of audio and ONE transcript file and evaluate WER for each


# $1 = full path location of where to write results file
# $2 = full path location of audio
# $3 = filetype for audio (e.g. ".wav")             #TODO is this parameter even used right now?
# $4 = full path location of gold transcript file
# $5 = full path location of Watson transcripts (using prepareTranscript.pl)
            #[same as audio].wat
# $6 = full path location to a temp folder used in the script
                #linux = /tmp/kaldiEvaluate/
                #mac = ${TMPDIR}kaldiEvaluate/      #TODO figure out why this doesn't work on a mac


results=$1
audio_dir=$2
audio_type=$3
gold_file=$4
wat_dir=$5

tmpFolder=$6
gold_dir=${tmpFolder}gold_dir/

mkdir $tmpFolder
mkdir $gold_dir

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

echo "Checking gold transcript file"

#write each utterance ID to golds.list
cut -d' ' -f1 ${gold_file} >> ${tmpFolder}goldsUnsorted.list

#sort golds list
sort ${tmpFolder}goldsUnsorted.list >> ${tmpFolder}golds.list

echo "Building list of files to evaluate"

#get list of files for which both gold transcript and wave exist
comm -12 ${tmpFolder}waves.list ${tmpFolder}golds.list >> ${tmpFolder}common.list

#if .wat transcripts don't yet exist
if [ ! -d "$wat_dir" ]; then

    #make directory for .wat
    mkdir $wat_dir

    #iterate through commons.list
    while read filename
    do

        echo "Calling Watson client"
        #send to Watson client
        ./callWatson.sh ${audio_dir}${filename}.wav ${wat_dir}${filename}.json 1 1.0

        #wait two seconds for client to close
        sleep 2

        echo "Parsing Watson output"
        #parse json
        python ../PVtrans_pre/parseWatsonJSON.py ${wat_dir}${filename}.json ${wat_dir}${filename}.raw

        echo "Cleaning Watson output"
        #clean transcript for WER comparison
        ../PVtrans_pre/prepareTranscript.pl ${wat_dir}${filename}.raw ${filename} ${wat_dir}${filename}.wat

        #remove .json and .raw file, keeping only cleaned .wat
        rm ${wat_dir}${filename}.raw
        rm ${wat_dir}${filename}.json

        #make a file of only that utterance ID (.gold)
        grep  -F $filename $gold_file | uniq >> ${gold_dir}${filename}.rawGold          #why is grep duplicating?  uniq fixes it

        #clean transcript for WER comparison
        ../PVtrans_pre/prepareTranscript.pl ${gold_dir}${filename}.rawGold ${filename} ${gold_dir}${filename}.gold

        echo "Writing results to file"
        #prepare results file
        echo "============" >> $results
        echo $filename >> $results
        #send resulting .wat transcript and .gold transcript to compute-wer.cc
        ../../src/bin/compute-wer --text --mode=present ark:${gold_dir}${filename}.gold ark:${wat_dir}${filename}.wat >> $results

        #delete .gold file
        rm ${gold_dir}${filename}.gold

    done < ${tmpFolder}common.list

else

    #iterate through commons.list
    while read filename
    do
        #make a file of only that utterance ID (.gold)
#        grep  -F $filename $gold_file >> ${gold_dir}${filename}.gold
        grep  -F $filename $gold_file | uniq >> ${gold_dir}${filename}.rawGold          #why is grep duplicating?  uniq fixes it

        #clean transcript for WER comparison
#        ./prepareTranscript.pl ${gold_dir}${filename}.rawGold ${filename} ${gold_dir}${filename}.gold
        ../PVtrans_pre/prepareTranscript.pl ${gold_dir}${filename}.rawGold "" ${gold_dir}${filename}.gold

        echo "Writing results to file"
        #prepare results file
        echo "============" >> $results
        echo $filename >> $results
        #send resulting .wat transcript and .gold transcript to compute-wer.cc
        ../../src/bin/compute-wer --text --mode=present ark:${gold_dir}${filename}.gold ark:${wat_dir}${filename}.wat >> $results

        #delete .gold file
#        rm ${gold_dir}${filename}.gold

    done < ${tmpFolder}common.list

fi


#cleaning up temp files
rm -r $tmpFolder