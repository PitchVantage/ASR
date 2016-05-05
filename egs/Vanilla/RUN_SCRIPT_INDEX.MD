# Tools Index

This file is an ongoing list .run scripts for the Vanilla egs folder.
 
**When updating this file, do so from `pitchKaldi` branch!**

*Keep descriptions short*

| filename | description  | parameterized |
| --- | --- | --- | --- | --- |
| run_generalized.sh | end-to-end test and train | y |
| | | | | <!--- keeps a blank line between folder types -->
| run_generalized_segments.sh  | end-to-end train and test audio into segments | y | 
| run_generalized_segments_TRAIN.sh  | end-to-end train and test that breaks train audio only into segments | y |
| run_generalized_dev.sh | keeps acoustic training but retrains the language model | y |
| | | | | <!--- keeps a blank line between folder types -->
| run_generalized_test_demo.sh  | keeps acoustic and language model training. tests and transcribes | y | 



