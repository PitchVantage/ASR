#!/usr/bin/env bash

# formats all .DOT transcripts in WSJ and then concatenates into one list

# $1 = location of entire collection (uppermost folder)
# $2 = output location for "transcripts" file (path/)

#capture all .DOT files in $1 recursively with file type $2 +
ALLFILES=( $(find $1 -name *.DOT -type f) )

#make variable for path to transcripts
transcriptLocation=${2}transcripts

#iterate over list of files and format
for i in ${ALLFILES[@]}; do
    ./formatTranscript.pl $i >> $transcriptLocation
done

