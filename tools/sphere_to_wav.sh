#!/usr/bin/env bash


#take as input:
# (0) the location of the entire WSJ collection
# (1) the location of sph2pipe
# ./sph2pipe [input] [output.wav]

for disc in $( ls ); do         #13_1_1
    #TODO capture this to a list
    find $i -type f             #will print out list of all files recursively
    #TODO filter list for .WV1
    #run ./sphpipe