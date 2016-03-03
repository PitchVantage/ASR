#!/usr/bin/env bash


#take as input:
# $1 the location of the entire WSJ collection


#capture all files recursively with type .WV1
ALLFILES=( $(find $1 -name "*.WV1" -type f) )

#iterate over list of files and run sph2pipe
for i in ${ALLFILES[@]}; do
    /media/mcapizzi/data/Github/kaldi/tools/sph2pipe_v2.5/sph2pipe $i "${i%.WV1}.wav"              #renames from .WV1 to .wav
done

