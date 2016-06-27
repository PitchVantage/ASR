#!/usr/bin/env bash

#calls goVivace client (which should be in /tools

# $1 = filetype of output ("json" or "text")
# $2 = full file path of single audio to transcribe
# $3 = full path of output location

#./callGoVivace.sh text path/to/sample_audio.wav path/to/transcription.txt

##:49169 is `updated` client - currently (6/2016) NOT performing well
##:49165 is `old` client

if [ "$1" == "json" ]; then
    ../goVivaceClient -u ws://pitchvantage.govivace.com:49165/client/ws/speech --save-json-filename $3 $2
#    ../goVivaceClient -u ws://pitchvantage.govivace.com:49169/client/ws/speech --save-json-filename $3 $2
else
    #bug in client requires json be generated along with plain text
    ../goVivaceClient -u ws://pitchvantage.govivace.com:49165/client/ws/speech --save-json-filename unneeded.json --save-text-filename $3 $2
#    ../goVivaceClient -u ws://pitchvantage.govivace.com:49169/client/ws/speech --save-json-filename unneeded.json --save-text-filename $3 $2

    #remove unneeded json
    rm unneeded.json
fi



