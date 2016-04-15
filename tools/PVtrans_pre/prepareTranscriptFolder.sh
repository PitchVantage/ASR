#!/usr/bin/env bash

#prepares a folder structure containing transcripts (using prepareTranscript.pl)

# $1 = folder containing transcripts
# $2 = file extension of transcripts (e.g. .txt)
# $3 = location for clean transcripts

#get a list of all files (recursively)
ALLTRANS=( $(find $1 -name *$2 -type f) )

#iterate over files and process using prepareTranscript.pl
for i in ${ALLTRANS[@]}; do
    base=$(basename $i)
    ./prepareTranscript.pl $i ${3}${base}
done


