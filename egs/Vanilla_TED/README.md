[![Build Status](https://travis-ci.org/kaldi-asr/kaldi.svg?branch=master)]
(https://travis-ci.org/kaldi-asr/kaldi)

Vanilla PV_Kaldi Egs Folder
================================

To use the Vanilla Egs folder, provide all files listed in the input folder (see file snippets for examples or use input file in Best_Results_WSJ as an example). 

Input Folder
  - lexicon_nosil.txt (Lexicon or dictionary without silence)
  - lexicon.txt (Lexicon with silence)
  - phones.txt (List of phones)
  - task.arpabo (Language model)
  - transcripts (Gold transcripts)

Command Line: ./run_generalized.sh -p [# of processors] -n [path/to/training/.wav/files] -t [path/to/testing/.wav/files] -i [path/to/input/folder]

Example Command Line: ./run_generalized.sh -p 4 -n /Volumes/poo/Test_dir_one_folder/ -t /Volumes/poo/Easy_Demo/ -i Best_Results_WSJ/input/

See RUN_SCRIPT_INDEX.MD for other run script options.

