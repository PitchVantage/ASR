Steps to Building Kaldi Experiments from a Corpus
==================================================

New corpora may require different pre-processing steps that are specific to the new corpora. The following document outlines the steps required to build a Kaldi experiment from the TEDLIUM Release 1 corpus. The steps outlined are for an initial end-to-end training and testing experiment using the run_generalized.sh script. For other run script options see `RUN_SCRIPT_INDEX.MD`.

Files Needed for run_generalized.sh
------------------------------------

Input files:
- lexicon_nosil.txt
- lexicon.txt
- phones.txt
- task.arpabo
- transcripts

Audio files:
- training .wav files
- testing .wav files

How to Create Input Files
--------------------------
1) lexicon_nosil.txt
- `tools/PVlexicon_pre/UpperCase_Dict.py`
- Add `XYZ XYZP` to lexicon_nosil.txt 
- Add lexicon_nosil.txt to egs input folder

2) lexicon.txt
- Copy lexicon_nosil.txt in input folder and rename it lexicon.txt
- Add the following to lexicon.txt:
```
<SIL> SILc
<SILI> SIL
<UNK> SPOKEN_NOISE
<unk> SPOKEN_NOISE
XYZ XYZP
```

3) phones.txt
- Copy phones.txt from Vanilla egs folder or use corpora specific phones list
- Add `XYZP` to phone.txt

4) transcripts
- `tools/PVlm_pre/cleanAllTEDLIUM.sh`
- Copy the output of `cleanAllTEDLIUM.sh` into a file with the same file format and name as `egs/Vanilla/input/transcripts`. 

5) task.arpabo
- Use formatted transcript. See `tools/PVlm_pre/cleanAllTEDLIUM.sh`.
- `tools/PVlm_pre/Format_Transcript_for_LM.py`
- `tools/PVlm_pre/Replace_w_XYZ.py`
- `tools/PVlm_pre/Create_lm.sh`
- Copy the output of `Create_lm.sh` into a file with the same file format and name as `egs/Vanilla/input/task.arpabo`. 
- Next run the same file you used with `tools/PVlm_pre/Create_lm.sh` and run `tools/PVlm_pre/Create_lm_start_end.sh`
- From the output of `Create_lm_start_end.sh`, copy the start and end of sentences into your task.arpabo file. The format will like this this:

```
-5.84485	<s>	-0.658445
-3.25212	</s>
```

How to Create Audio Files
--------------------------
1) Convert to .wav
- `tools/PVacous_pre/sphere_to_wav.sh`
- If multiple audio file extensions exist (i.e. .WV1 and .WV2), then run sphere_to_wav.sh twice. 

Finally, make sure to create a README.txt file in the input folder and describe any changes or additions you make for your specific corpus.
