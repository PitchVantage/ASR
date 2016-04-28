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
| PVacous_pre | sphere_to_wav.sh | converts `.sph` to `.wav` using `sph2pipe` | y |
| | | | | <!--- keeps a blank line between folder types -->
| PVanalysis | callGoVivace.sh | transcribes single audio file with `goVivace` | y |
| PVanalysis | findPercentNE.py | attempts to identify (coarsely) the percent of named entities in a file | y |
| PVanalysis | makeDataFrame.py | makes a `pandas` dataframe out of a `.results` file | y |
| PVanalysis | NE-rate.py | *rough* attempt to estimate ASR success on named entities | y |
| | | | | <!--- keeps a blank line between folder types -->
| PVlexicon_pre | mergeLexicons.py | merges two lexicon files into one | y |
| PVlexicon_pre | UpperCase_Dict.py | changes a lexicon.txt file into uppercase format| y |
| | | | | <!--- keeps a blank line between folder types -->
| PVlm_pre | cleanCOCA.py | prepares original COCA corpus for use in language model | y |
| PVlm_pre | cleanAllTEDLIUM.sh | runs `cleanTEDLIUM.py` on entire folder of `.stm` files (for lm or trans) | y |
| PVlm_pre | cleanTEDLIUM.py | prepares single TEDLIUM transcript file for use (in lm or for transcripts)| y |
| PVlm_pre | Create_lm.sh | creates a trigram lm from a cleaned lm transcript| y |
| PVlm_pre | Create_lm_start_end.sh | creates a trigram lm from a cleaned lm transcript with start and end markers| y |
| PVlm_pre | Format_Transcript_for_LM.py | prepares a single transcript file for use in lm | y |
| PVlm_pre | Replace_w_XYZ.py | replaces words not in the lexicon with XYZ for a single lm transcript file | y |
| | | | | <!--- keeps a blank line between folder types -->
| PVmisc | geVocabSize.py | calculates the vocabulary size of a subset of transcripts | y | 
| | | | | <!--- keeps a blank line between folder types -->
| PVtrans_pre | cleanTranscriptDuplicates.py | removed duplicates transcripts that were generated | n |
| PVtrans_pre | Create_Test_Transcript.sh | create a transcript file with only items from the test set | y |
| PVtrans_pre | formatTranscript.pl | swaps `text UttID` to `UttID text` | y | 
| PVtrans_pre | formatWSJTranscripts.sh | concatenates all `.DOT` files into one file | y |
| PVtrans_pre | prepareTranscript.pl | cleans up raw transcript files for WER calculation | y |
| Pvtrans_pre | prepareTranscriptFolder.sh | runs `prepareTranscript.pl` on folder of transcripts | y |

