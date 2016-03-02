1. make transcript look like this in perl:

    ```
    "UTT-A word-A word-A; <eps> word-A; word-B word-B; word-C <eps>; word-D word-D; word-E word-X";
    ```

2. run `wer_per_utt_details.pl` over #1:

    input:
    ```
    
    ```
    "UTT-A word-A word-A; <eps> word-A; word-B word-B; word-C <eps>; word-D word-D; word-E word-X";
    ```
    
    output:
    
    ```
    UTT-A ref  word-A   <eps>  word-B  word-C  word-D  word-E
    UTT-A hyp  word-A  word-A  word-B   <eps>  word-D  word-X
    UTT-A op      C       I       C       D       C       S
    UTT-A #csid 3 1 1 1
    ```
   
   This will show insertions (`I`), deletions (`D`), substitutions (`S`), or correct (`C`) for each word.
   `#csid` field: counts of Corr, Sub, Ins and Del
   
3. run `wer_ops_details.pl` to see which words the system gets wrong most often:

    input: 

    ```
        UTT-A ref  word-A   <eps>  word-B  word-C  word-D  word-E
        UTT-A hyp  word-A  word-A  word-B   <eps>  word-D  word-X
        UTT-A op      C       I       C       D       C       S
        UTT-A #csid 3 1 1 1
    ```
    
    output:
    
    ```
    correct       word-A  word-A  1
    correct       word-B  word-B  1
    correct       word-D  word-D  1
    deletion      word-C  <eps>   1
    insertion     <eps>   word-A  1
    substitution  word-E  word-X  1
    ```
    