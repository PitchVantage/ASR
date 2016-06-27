#!/usr/bin/env bash

#This method will run cleanTEDLIUM.py over all the .stm files in the TEDLIUM corpus and concatenates into one long .txt file

# -l = upper-most folder location of all .stm
# -n = use only train and dev
        #1 if yes
        #0 if no
# -a = use train, dev, and test
        #1 if yes
        #0 if no
# -t = target location for concatenated file
# -u = add utterance ID as first token for each line

#./cleanAllTEDLIUM.sh -l full/path/to/corpus [-n 1|-a 1] -t full/path/to/target.txt -u 1

#default values for variables
#0 or 1
trainOnly=0
withTest=0
uttID=0

while getopts "l:n:a:t:u:" opt; do
    case $opt in
        l)
            location=$OPTARG
            ;;
        n)
            trainOnly=$OPTARG
            ;;
        a)
            withTest=$OPTARG
            ;;
        t)
            target=$OPTARG
            ;;
        u)
            uttID=$OPTARG
            ;;
        \?)
            echo "wrong parameters"
            exit 1
            ;;
    esac
done

if [[ "$withTest" -eq 1 && "$trainOnly" -eq 1 ]]; then
    echo "Select only -n or -a, but not both"
    exit 1
elif [ "$withTest" -eq 1 ]; then
    ALLFILES=( $(find $location -name *.stm -type f) )

    #iterate over files and process using cleanTEDLIUM.py
    for i in ${ALLFILES[@]}; do
        if [ "$uttID" -eq 1 ]; then
            python cleanTEDLIUM.py $i t >> $target
        else
            python cleanTEDLIUM.py $i f >> $target
        fi
    done
else
    #do this for both train and dev folders
    for folder in /train/ /dev/; do
        ALL=( $(find ${location}${folder} -name *.stm -type f) )

        #iterate over files and process using cleanTEDLIUM.py
        for i in ${ALL[@]}; do
            if [ "$uttID" -eq 1 ]; then
                python cleanTEDLIUM.py $i t >> $target
            else
                python cleanTEDLIUM.py $i f >> $target
            fi
        done
    done
fi