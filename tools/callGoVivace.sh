#!/usr/bin/env bash

#calls goVivace client (which should be in /tools

# $1 = filetype ("json" or "text")
# $2 = full audio file path
# $3 = output location (full path)

if [ "$1" == "json" ]; then
    ./goVivaceClient -u ws://pitchvantage.govivace.com:49165/client/ws/speech --save-json-filename $3 $2
else
    #bug in client requires json be generated along with plain text
    ./goVivaceClient -u ws://pitchvantage.govivace.com:49165/client/ws/speech --save-json-filename unneeded.json --save-text-filename $3 $2

    #remove unneeded json
    rm unneeded.json
fi



