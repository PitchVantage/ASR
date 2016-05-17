There are three test sets:

Test Set | Description | Size x Length | Reference
---|---|---
WSJ | Read and spontaneous speech | X single sentences | 
TED | Full TED talks | x 20+mins |  
Pitch | Science related talks | 4 x 10+mins | PitchVantage proprietary data

Below are baseline results from `GoVivace` run in 05/2016:

System | Test Data | WER
|---|---|---
GoVivace | WSJ | 17.3%
GoVivace | TED | 14.2%
GoVivace | Pitch | 21.1%


Below are up-to-date results from `kaldi`:

System | Date (mo/yr) | Acoustic Data | LM/Lexicon | Test Data | WER
---|---|---|---|---|---
kaldi | 04/16 | WSJ | WSJ | WSJ |
kaldi | 05/16 | WSJ | WSJ | TED |
kaldi | 05/16 | WSJ | WSJ | Pitch |
kaldi | 05/16 | TED | WSJ + TED | TED |