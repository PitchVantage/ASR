# Tools Index

This file is an ongoing list of the supplementary tools that we are building as we progress with `kaldi`.
 
**When updating this file, do so from `pitchKaldi` branch!**

Below are the subfolders for `tools/`:

- `PVacous_pre` = scripts used for pre-processing of acoustic files to be used in the model
- `PVanalysis` = scripts used in the analysis of model results
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
| PVlm_pre | cleanCOCA.py | prepares original COCA corpus for use in language model | y |
| | | | | <!--- keeps a blank line between folder types -->
| PVmisc | geVocabSize.py | calculates the vocabulary size of a subset of transcripts | y | 
| | | | | <!--- keeps a blank line between folder types -->
| PVtrans_pre | cleanTranscriptDuplicates.py | removed duplicates transcripts that were generated | n |
| PVtrans_pre | formatTranscript.pl | swaps `text UttID` to `UttID text` | y | 
| PVtrans_pre | formatWSJTranscripts.sh | concatenates all `.DOT` files into one file | y |
| PVtrans_pre | prepareTranscript.pl | cleans up raw transcript files for WER calculation | y |
| Pvtrans_pre | prepareTranscriptFolder.sh | runs `prepareTranscript.pl` on folder of transcripts | y |

