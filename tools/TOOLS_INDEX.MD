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
| PVacous_pre | | | |
| | | | |
| PVanalysis | callGoVivace.sh | transcribes single audio file with `goVivace` | y |
| PVanalysis | findPercentNE | attempts to identify (coarsely) the percent of named entities in a file | y |
| | | | |
| PVlm_pre | cleanCOCA.py | prepares original COCA corpus for use in language model | y |
| | | | |
| PVmisc | | | | 
| | | | |
| PVtrans_pre | cleanTranscriptDuplicates.py | removed duplicates transcripts that were generated | n |
