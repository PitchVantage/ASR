Recommended Kaldi Experiments
================================

The following is a list of recommended Kaldi experiments that require more than 6 GB of memory to compute. 

Training Data: 
- WSJ (unsegmented)
- TED (segmented)

Language Model:
- Segmented: Seg_COCA_WSJ.arpabo (COCA and WSJ are segmented)
- Partially Segmented: PartialSeg_COCA_WSJ_TED.arpabo (COCA and WSJ are segmented, but TED is not segmented)
- Unsegmented: UnSeg_COCA_WSJ_TED.arpabo (COCA, WSJ, and TED are unsegmented)

Test Data:
- WSJ Test (unsegmented)
- TED Test (segmented)
- PitchVantage Test (unsegmented)

Complete all combinations of the following parameters: 2 acoustic training sets x 3 language models x 3 test sets for a total of 18 experiments.

To run the experiments, create an input folder with the particular parameters you are testing (see Vanilla egs README.md). Then, open a new terminal window and navigate to the Vanilla egs folder. Finally, use the appropriate .run script to start the experiment (see RUN_SCRIPT_INDEX.MD).

The following are example command lines for 2 different types of experiments:

1) TED Training Data x Segmented Language Model x PitchVantage Test Data

```
HLT-ADMINs-Mac-Pro:Vanilla_A_TED_L_Seg_T_PV hlt-admin$ ./run_generalized_segments_TRAIN.sh -p 4 -n /Volumes/My_Passport_Mac/TED_Kaldi_Files/TED_wav/train/ -t /Volumes/My_Passport_Mac/Final_PV/PV_Test_Folders/PitchVantage_Test/PV_test_audio/ -i /Volumes/My_Passport_Mac/Final_PV/Input_Parameters/input/Vanilla_A_TED_L_Seg_T_PV/ -g /Volumes/My_Passport_Mac/Final_PV/Input_Parameters/input/Vanilla_A_TED_L_Seg_T_PV/TEDLIUM_release1_segmentsTRAIN
``` 

2) TED Training Data x Segmented Language Model x TED Test Data

``` 
HLT-ADMINs-Mac-Pro:Vanilla_A_TED_L_Seg_T_TED hlt-admin$ ./run_generalized_segments.sh -p 4 -n /Volumes/My_Passport_Mac/TED_Kaldi_Files/TED_wav/train/ -t /Volumes/My_Passport_Mac/TED_Kaldi_Files/TED_wav/test/ -i /Volumes/My_Passport_Mac/Final_PV/Input_Parameters/input/Vanilla_A_TED_L_Seg_T_TED/ -g /Volumes/My_Passport_Mac/Final_PV/Input_Parameters/input/Vanilla_A_TED_L_Seg_T_TED/TEDLIUM_release1_segmentsTRAIN -z /Volumes/My_Passport_Mac/Final_PV/Input_Parameters/input/Vanilla_A_TED_L_Seg_T_TED/TEDLIUM_release1_segmentsTEST
``` 

Notice that the first example only has a segments file for the TED training data, but not for the PitchVantage test data. Also, it uses the ./run_generalized_segments_TRAIN.sh instead of the ./run_generalized_segments.sh. This is becuase the TED training data is segmented, but the PitchVantage test data is not segmented. However, in the second example both the training and test data are segmented so the ./run_generalized_segments.sh. script is used and both train/test data have a segments file included in the command line.

Double check when you're running the experiments that you are using the correct file path for your computer and the correct run.sh script for the parameters you are using (see RUN_SCRIPT_INDEX.MD).
