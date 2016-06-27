There are three test sets:

Test Set | Description | Size x Length | Reference
---|---|---
WSJ | Read and spontaneous speech |  620 X single sentences | Continuous Speech Recognition CSR Corpus: Phase 2 (WSJ1)
TED | Full TED (talks segmented arbitrarily) | 11 x 20+mins (segmented) | TED-LIUM Release 1
Pitch | Science related talks | 4 x 10+mins (unsegmented) | PitchVantage proprietary data

Below are baseline results from `GoVivace` run in 05/2016:

System | Test Data | WER
|---|---|---
GoVivace | WSJ | 17.3%
GoVivace | TED | 14.2%
GoVivace | Pitch | 21.1%


Below are up-to-date results from `kaldi`:

System | Date (mo/yr) | Acoustic Data | LM/Lexicon | Test Data | WER
---|---|---|---|---|---
kaldi | 04/16 | WSJ | WSJ w/ XYZ | WSJ w/ XYZ | 20.02%
kaldi | 04/16 | TED - segmented | TED w/ XYZ | TED - segmented w/ XYZ | 41.46%
kaldi | 05/16 | TED - segmented | TED w/ XYZ | Pitch - unsegmented w/ XYZ | 63.3%
kaldi | 05/16 | WSJ | WSJ w/ XYZ | Pitch - unsegmented w/ XYZ | 75.9%