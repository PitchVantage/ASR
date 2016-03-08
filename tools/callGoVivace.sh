#!/usr/bin/env bash

#calls goVivace client (which should be in /tools

# $1 = filetype ("json" or "text")
# $2 = full audio file path
# $3 = output location (full path)

if [ "$1" == "json" ]; then
    ./goVivaceClient -u ws://pitchvantage.govivace.com:49165/client/ws/speech --save-json-filename $3 $2
else
    ./goVivaceClient -u ws://pitchvantage.govivace.com:49165/client/ws/speech --save-text-filename $3 $2
fi
