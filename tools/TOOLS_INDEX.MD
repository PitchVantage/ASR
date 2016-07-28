# Tools Index

This file is an ongoing list of the supplementary tools that we are building as we progress with `kaldi`.
 
**When updating this file, do so from `pitchKaldi` branch!**

Below are the subfolders for `tools/`:

- `PVacous_pre` = scripts used for pre-processing of acoustic files to be used in the model
- `PVanalysis` = scripts used in the analysis of model results
- `PVlexicon_pre` = scripts used for pre-processing files to be used in building the lexicon
- `PVlm_pre` = scripts used for pre-processing files to be used in building the language model
- `PVmisc` = doesn't fit anywhere else
- `PVtrans_pre` = scripts used for pre-processing transcript files to be used in training of the model 

*Keep descriptions short*

| folder | filename | description | parameterized | 
| --- | --- | --- | --- | --- |
| *PVmisc* | *sample.py* | *a few words to describe the file* | *y* |
| | | | | <!--- keeps a blank line between folder types -->
| PVacous_pre | LIUM_seg_to_kaldi_seg.py | converts `.seg` file from LIUM `.jar` to `kaldi` format | y |
| PVacous_pre | sphere_to_wav.sh | converts `.sph` to `.wav` using `sph2pipe` | y |
| | | | | <!--- keeps a blank line between folder types -->
| PVanalysis | callGoVivace.sh | transcribes single audio file with `goVivace` | y |
| PVanalysis | callWatson.sh | transcribes single audio file with `Watson` |y|
| PVanalysis | compareKaldiGoVivace.sh | compares WER from `kaldi` and `Go Vivace` on a test sets | y | 
| PVanalysis | evaluateGoVivace-multiTranscript.sh | gets `Go Vivace` results on audio with multiple transcript files | y |
| PVanalysis | evaluateGoVivace-singleTranscript.sh | gets `Go Vivace` results on audio with one master transcript file | y |
| PVanalysis | evaluateWatson-singleTranscript.sh | gets `Watson` results on audio with one master transcript file |y|
| PVanalysis | findPercentNE.py | attempts to identify (coarsely) the percent of named entities in a file | y |
| PVanalysis | makeDataFrame.py | makes a `pandas` dataframe out of a `.results` file | y |
| PVanalysis | NE-rate.py | *rough* attempt to estimate ASR success on named entities | y |
| PVanalysis | visualize_errors.py | generates `.html` output with errors color-coded | y |
| | | | | <!--- keeps a blank line between folder types -->
| PVlexicon_pre | check_phones_in_lexicon.py | ensures that all `phones` are in `lexicon` | y |
| PVlexicon_pre | merge_lexicons.py | merges two lexicon files into one | y |
| PVlexicon_pre | merge_phones.py | merges two phones files into one | y |
| PVlexicon_pre | UpperCase_Dict.py | changes a lexicon.txt file into uppercase format| y |
| PVlexicon_pre | Remove_Duplicates.py | remove duplicates from input file | y |
| | | | | <!--- keeps a blank line between folder types -->
| PVlm_pre | cleanCOCA.py | prepares original COCA corpus for use in language model | y |
| PVlm_pre | cleanAllTEDLIUM.sh | runs `cleanTEDLIUM.py` on entire folder of `.stm` files (for lm or trans) | y |
| PVlm_pre | cleanTEDLIUM.py | prepares single `TEDLIUM` transcript file for use (in lm or for transcripts)| y |
| PVlm_pre | create_lm.sh | creates an `ARPA`-style language model from a list of `.txt` files | y |
| PVlm_pre | find_not_in_lexicon_arpa.py | creates a list of OOV words in a given LM not in a given lexicon | y | 
| PVlm_pre | find_not_in_lexicon_text.py | creates a list of OOV words in a given LM not in a given list of `.txt` files | y | 
| PVlm_pre | preprocess_for_lm.py | pre-processes a list of `.txt` files for us in building a language model | y |
| PVlm_pre | prune_lm.sh | prunes an existing language model by removing "unnecessary" n-grams| y |
| PVlm_pre | Replace_w_XYZ.py | replaces words not in the lexicon with XYZ for a single lm transcript file | y |
| PVlm_pre | Replace_w_XYZ_and_list_of_unknown_words.py | replaces words not in the lexicon with XYZ for a single lm transcript file and keeps a list of all words replaced with XYZ | y |
| | | | | <!--- keeps a blank line between folder types -->
| PVmisc | getVocabSize.py | calculates the vocabulary size of a subset of transcripts | y | 
| | | | | <!--- keeps a blank line between folder types -->
| PVtrans_pre | cleanTranscriptDuplicates.py | removed duplicates transcripts that were generated | n |
| PVtrans_pre | Create_Test_Transcript.sh | create a transcript file with only items from the test set | y |
| PVtrans_pre | formatTranscript.pl | swaps `text UttID` to `UttID text` | y | 
| PVtrans_pre | formatWSJTranscripts.sh | concatenates all `.DOT` files into one file | y |
| PVtrans_pre | parseWatsonJSON.py | parses the original `Watson` `.json` into plain `txt` |y|
| PVtrans_pre | prepareTranscript.pl | cleans up raw transcript files for WER calculation | y |
| PVtrans_pre | prepareTranscriptFolder.sh | runs `prepareTranscript.pl` on folder of transcripts | y |
| PVtrans_pre | unmergeTranscripts.py | makes individual transcript files from a master transcript file | y |
