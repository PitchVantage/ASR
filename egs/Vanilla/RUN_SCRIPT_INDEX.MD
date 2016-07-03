# Tools Index

This file is an ongoing list .run scripts for the Vanilla egs folder.
 
**When updating this file, do so from `pitchKaldi` branch!**

*Keep descriptions short*

| filename | description  | parameterized | required folders/files |
| --- | --- | --- | --- | --- |
| run_generalized.sh | end-to-end test and train | y | `input/` |
| | | | | <!--- keeps a blank line -->
| run_generalized_segments.sh  | end-to-end train and test audio into segments | y | `input/` |
| run_generalized_segments_TRAIN.sh  | end-to-end train and test that breaks train audio only into segments | y | `input/` |
| run_generalized_dev.sh | keeps acoustic training but retrains the language model | y | `input/`, `exp/`, `mfcc/`, `data/` |
| | | | | <!--- keeps a blank line -->
| run_generalized_test_demo.sh  | keeps acoustic and language model training, tests, and transcribes | y | `input/`, `exp/`, `mfcc/`, `data/`, `graph/`, `*.mdl` |



