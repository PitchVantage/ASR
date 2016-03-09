We have all the data for using the `s5` scripts {catalog number LDC94S13A (WSJ1)}.  We did have to make a few changes to some scripts.  See below.

1. We had to update the location of the WSJ data.  {`run_Edit.sh` line 22}

    - We do not think we have WSJ0, so we haven't done anything with that yet.

2. The scripts expected a WSJ-folder naming system of ##-#.# and we have ##_#_#.  Since it seemed to be easier to do so, we just changed the naming system of our data to match what the scripts expect.

3. Since we don't have WSJ0, we removed reference to any data (training and testing) of WSJ0. {`wsj_data_prep_Edit.sh` line 77}.  

    - `$wsj1` is the path to WSJ ending in `*`
    
    - line 49 says `ln -s $* links` (making a symbolic link to the audio data).  We changed it to our hard-coded variable (`$wsj1`)

    - line 83 says `grep -v -i 11-2.1/wsj0/si_tr_s/401 > train_si284.flist`.  Our theory is that this is taking *everything but* (`grep -v` is inverse match) section 401 of disc 11-2.1 and writing it to this training file.
    
        - we replaced `11-2.1/wsj0/si_tr_s/401` with `13-11.1/wsj1/si_tr_s/4a8`
   
    - line 86 tests to make sure the appropriate number of training items appears (since we changed it)


**As of 3/7/16, we decided to abandon modifying the WSJ (as a waste of time, that is not generalizable) and instead building 