#!/usr/bin/env bash

#calls Watson API
#see https://www.ibm.com/smarterplanet/us/en/ibmwatson/developercloud/doc/speech-to-text/output.shtml

# $1 = full file path of single audio to transcribe
# $2 = full path of output location (of `.json`)
# $3 = number of alternative transcriptions to capture
# $4 = alternative word threshold *must include leading 0*, e.g. `0.8` (between 0 and 1)

# ./callWatson.sh /media/mcapizzi/1D62228A516FBBAA/LEXARbackup/kaldi/acoustic_data/WSJ_Train_sample/4A0A010Q.wav /home/mcapizzi/Desktop/test.json 3 0.8

audio_path=$1
output_path=$2
num_alternatives=$3
alternative_word=$4

curl -X POST -u 08567b65-0f7d-419a-b40c-4be1203e6d8c:3nJPU0zmYenG \
--header "Content-Type: audio/wav" \
--header "Transfer-Encoding: chunked" \
--data-binary @$1 "https://stream.watsonplatform.net/speech-to-text/api/v1/recognize?continuous=true&timestamps=true&max_alternatives="${num_alternatives}"&word_alternatives_threshold="${alternative_word} \
> ${output_path}
