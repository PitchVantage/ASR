#!/usr/bin/env bash


#take as input:
# (0) the location of the entire WSJ collection
# (1) the location of sph2pipe

#capture all files recursively with type .WV1
ALLFILES=( $(find $1 -name "*.WV1" -type f) )

#iterate over list of files and run sph2pipe
for i in ${ALLFILES[@]}; do
    $2/sph2pipe $i "${i%.WV1}.wav"              #renames from .WV1 to .wav
done

