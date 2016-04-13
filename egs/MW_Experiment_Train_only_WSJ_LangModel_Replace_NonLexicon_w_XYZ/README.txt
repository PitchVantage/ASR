
Information about this egs folder:

Egs Folder: MW_Experiment_Test_Train_WSJ_LangModel_Replace_NonLexicon_w_XYZ
Version: Creating lang model from Train and Test transcripts AND cleaning transcripts so that all words that are NOT in the lexicon are replaced with XYZ. XYZ is also added to the lexicon as being transcribed as XYZPHONEME and XYZPHONEME is added to the phones list file. Transcription does NOT have XYZ replaced in the transcription.
Language Model: Created from Train and Test transcripts. No <unk> included. ALL words also present in lexicon. 

Need to rerun Test and Train rather than use the development script. The new phoneme XYZP needs to be trained. 

Language model:
ngram  1=     21062
ngram  2=    214888
ngram  3=    394993

NEW CHANGES:
- Tried changing XYZ to <XYZ> (didn’t work) 
- Tried removing <XYZ> from lexicon_nosil.txt (didn’t work)
- Tried removing <XYZ> from lexicon (didn’t work)
- Tried adding <s> and </s> to language model (didn’t work)
- Changed back to XYZ
- Created transcripts for transcript file where all named entities are replaced with XYZ

Other note:
Changed XYZPHONE to XYZP

Acoustic Model: Triphones (?)
Training Files: WSJ Training
Testing: WSJ Testing
Run Script:  ./run_generalized.sh -p 4 -n /Volumes/poo/Test_dir_one_folder/ -t /Volumes/poo/Test_dir_one_folder/

Results: 

Previous Terminal Output Error:

dhcp-10-142-144-22:MW_Experiment_Test_Train_WSJ_LangModel_Replace_NonLexicon_w_XYZ hlt-admin$ ./run_generalized_development.sh -p 4 -t /Volumes/poo/Test_dir_one_folder/

####======================================####
#### BEGIN DATA + LEXICON + LANGUAGE PREP ####
####======================================####

Timestamp in HH:MM:SS (24 hour format)
14:19:42

Preparing test data
Finished preparing test data
Preparing language models for test
arpa2fst - 
Processing 1-grams
Processing 2-grams
Processing 3-grams
Connected 0 states without outgoing arcs.
FATAL: FstCompiler: Symbol "XYZ" is not mapped to any integer arc ilabel, symbol table = data/lang_test_tg/words.txt, source = standard input, line = 1184
ERROR: FstHeader::Read: Bad FST header: standard input
ERROR: FstHeader::Read: Bad FST header: standard input
fstisstochastic data/lang_test_tg/G.fst 
ERROR: FstHeader::Read: Bad FST header: data/lang_test_tg/G.fst
ERROR (fstisstochastic:ReadFstKaldi():kaldi-fst-io.cc:35) Reading FST: error reading FST header from data/lang_test_tg/G.fst
ERROR (fstisstochastic:ReadFstKaldi():kaldi-fst-io.cc:35) Reading FST: error reading FST header from data/lang_test_tg/G.fst

[stack trace: ]
0   fstisstochastic                     0x0000000101156114 _ZN5kaldi18KaldiGetStackTraceEv + 68
1   fstisstochastic                     0x00000001011573a8 _ZN5kaldi17KaldiErrorMessageD2Ev + 408
2   fstisstochastic                     0x0000000101157205 _ZN5kaldi17KaldiErrorMessageD1Ev + 21
3   fstisstochastic                     0x000000010115586b _ZN3fst12ReadFstKaldiESs + 395
4   fstisstochastic                     0x0000000101137920 main + 928
5   libdyld.dylib                       0x00007fff85b6a5fd start + 1

ERROR: FstHeader::Read: Bad FST header: data/lang_test_tg/G.fst
ERROR: FstHeader::Read: Bad FST header: tmpdir.g/empty_words.fst
Succeeded in formatting data.