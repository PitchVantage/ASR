###Created by Mohsen Mahdavi (mahdavi@email.arizona.edu), August 2016###


The files in this folder take an audio file, split it, send it to Google's ASR API, and return the transcripts.

The main run file is splitAndSendToGoogle.sh. Call it with one argument (the path to the input audio file).

Here are the steps that are taken when the main run file is run:

1- The silences in the audio file are detected using ffmpeg.
	The silence detection parameters can be changed in splitAndSendToGoogle.sh.
	The file temp/messy_silences.txt is created. It contains the silence times.

2- The code cleanSilFile.py is called.
	This piece of code creates a cleaner version of the list of the silence
	times, which is usable by splitter.py. This new cleaner file is in
	temp/silences.txt

3- The code splitter.py is called. It uses the silence times to actually segment  the audio file.
	The small audio chunks are stored in the directory "chunks".

4- The environmental variables necessary for Google's credential processes are set.
	The credential information are supposed to be in ser_acc_keyfile.

5- The code in Google-ASR/sendToGoogle.py is run. It sends the audio files to Google's API one by one.
	The number of chunks that should be used to google is sent as an argument to the python code
	by the main run file (splitAndSendToGoogle.sh). The default number is 80. So by default
	not all of the audio chunks are sent.
	The google credential information do not exist by default and should be provided.
	In particular, the file ser_acc_keyfile and the project code in the file sendToGoogle.py
	must be provided by the user. By default it is set as "***PutCodeHere***"


