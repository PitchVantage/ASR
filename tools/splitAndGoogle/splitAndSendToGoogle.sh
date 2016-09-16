#!/bin/bash
# Splits an audio file into smaller chunks cutting at pauses
#Takes 1 argument; the address of the original audio file

mkdir temp
ffmpeg -i "$1" -af silencedetect=noise=-20dB:d=0.5 -f null - 2> temp/messy_silences.txt
echo "#####Detected silence intervals."
python cleanSilFile.py
echo "#####Cleaned the list of silences."
rm -R chunks
mkdir chunks
python splitter.py "$1" &> temp/splittingLog.txt
echo "#####Successfully split the audio file."

export GOOGLE_APPLICATION_CREDENTIALS=/Users/Updates/Desktop/kaldi-helper-files/splitAndGoogle/Google-ASR/ser_acc_keyfile
python ./Google-ASR/sendToGoogle.py 80
echo "#####Called Google Speech API."

