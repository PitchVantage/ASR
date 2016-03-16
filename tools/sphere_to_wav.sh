#!/usr/bin/env bash

# $1 = location of the entire collection
# $2 = file extension of sphere (eg. .WV1)
# $3 = location for output files  NOTE: if no second argument given
        # output is in same location as original file

#capture all files in $1 recursively with type $2
ALLFILES=( $(find $1 -name *$2 -type f) )

echo "found ${#ALLFILES[@]} files"

#iterate over list of files and run sph2pipe
for i in ${ALLFILES[@]}; do
    #if second argument (location) is given, output to that location
    if [ "$#" -gt 2 ]; then
        base=$(basename $i)
        #get local path to /tools/sph2pipe_v2.5
        localPath=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )/sph2pipe_v2.5
        #run sph2pipe from local kaldi version found in tools
#        $localPath/sph2pipe $i -f wav $3"${base%.WV1}.wav"       #renames from original file type to .wav
        $localPath/sph2pipe $i -f wav $3"${base%$2}.wav"       #renames from original file type to .wav
    #else save to same location as original
    else
        #get local path to /tools/sph2pipe_v2.5
        localPath=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )/sph2pipe_v2.5
        #run sph2pipe from local kaldi version found in tools
#        $localPath/sph2pipe $i -f wav "${i%.WV1}.wav"       #renames from original file type to .wav
        $localPath/sph2pipe $i -f wav "${i%$2}.wav"       #renames from original file type to .wav
    fi
done

