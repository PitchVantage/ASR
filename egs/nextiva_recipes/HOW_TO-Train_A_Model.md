# Building a Model 

## HMM recipe
These instructions are modified from the `run.sh` script found in `egs/wsj`.  They utilize:
- triphones 
   - extracted from `mfcc`s with Linear Discriminant Analysis with Maximum Likelihood Linear Transformation (`LDA+MLLT`)
- trigram language model
- HMM

## Items needed

Six items are needed to build a model (if a hard-coded filename is used, it's included in the list:

1. Audio files
1. Transcripts: `transcripts`
1. Phones list `phones.txt`
1. Lexicons (2)
   - `lexicon.txt`
   - `lexicon_nosil.txt`
1. Language Model: `task.arpabo`

### Audio Files

Audio files **must be** `.wav` recorded in `Mono` at `16000Hz` (`32-bit float`)

The tool `sph2pipe` can be used to convert audio files from `.sph` to `.wav`.  
The script `tools/nextiva_tools/acoustic_pre/sphere_to_wav.sh` can be used to batch convert files.

### Transcripts

All transcripts must be saved in *one* file named `transcripts`.

This must have the following format:

```
44AA0101 THE FEMALE PRODUCES A LITTER OF TWO TO FOUR YOUNG IN NOVEMBER AND DECEMBER
44AA0102 NUMEROUS WORKS OF ART ARE BASED ON THE STORY OF THE SACRIFICE OF ISAAC
44AA0103 THEIR SOLUTION REQUIRES DEVELOPMENT OF THE HUMAN CAPACITY FOR SOCIAL INTEREST
44AA0104 HIS MOST SIGNIFICANT SCIENTIFIC PUBLICATIONS WERE STUDIES OF BIRDS AND ANIMALS
44AA0105 IN RECENT YEARS SHE HAS PRIMARILY APPEARED IN TELEVISION FILMS SUCH AS LITTLE GLORIA
44AA0106 THE PROCESS BY WHICH THE LENS FOCUSES ON EXTERNAL OBJECTS IS CALLED ACCOMMODATION
```

The transcripts must be in all capital letters.  Each line will represent a separate audio file (or segment), and the first word of each line is the `utteranceID` by which the audio file and transcript can be linked.  (The `utteranceID` and transcription are `\s` separated.)

If the transcript file consists of separate audio files (no segmentation used), the `utteranceID`
 must match the audio filename.
 
**INCLUDE EXPLANATION OF SEGMENTS**

### Phones

This file, named `phones.txt` is a list of all the individual phonemes used in the `lexicon`s.

This must have the following format:

```
AA
AE
AH
AO
AW
AY
B
CH
D
DH
```

Each line is a separate phoneme.  Every phoneme that appears in the `lexicon`s must appear in 
this list.

### Lexicons

These files represent all the words available to the model for selection.  (If a word is not in 
the `lexicon`, it cannot be predicted by the model).

They have the following format:

```
ZYSMAN Z IH S M AH N
ZYUGANOV Z Y UW G AA N AA V
ZYUGANOV Z Y UW G AH N AA V
ZYUGANOV'S Z Y UW G AA N AA V Z
ZYUGANOV'S(2) Z UW G AA N AA V Z
```

Each line is a separate word.  The first item in the row is the dictionary entry and the 
following items are a combination of phonemes (found in `phones.txt`) that make up the phonetic 
representation of the dictionary entry.  If there are multiple pronunciations in the `lexicon`, 
subsequent dictionary entries will be appended with `(n)` where `n` represents the `nth` 
alternate pronunciation available in the `lexicon`.

Two `lexicon` files exist, with the only difference being that `lexicon` contains the following 
four entries that `lexicon_nosil.txt` does not:

```
<SIL> SIL
<SLIL> SIL
<UNK> SPOKEN_NOISE
<unk> SPOKEN_NOISE
```

### Language Model

This recipe utilizes a trigram language model of the following format:

```
ngram  1=     99780
ngram  2=   4956786
ngram  3=  19938942
```

This header identifies the number of distinct `n-grams` used in the creation of the language model.

```
\1-grams:
-7.503	<s>	-2.09907
-3.77913	YESTERDAY	-1.03434
-2.16082	ON	-1.60336
...
-0.300728	NONNUCLEAR GERMANY AGAINST
-0.0887592	PARDEE COCHAIRMAN OF
-0.166518	KAZIS SAID </s>
-0.249556	KAZIS MANAGING DIRECTOR
-0.299845	TICOR TITLE INSURANCE
-0.300985	YETNIKOFF IS STEPPING
\end\

```

There are then separate sections for `unigram`, `bigrams`, and `trigrams` with a comment line 
`/n-grams:`.  

Each line represents an `n-gram` and it's negative log likelihood.  `Unigrams` and `bigrams` also
 contain a `backoff` likelihood.  The `negative log likelihood`, `n-gram`, and `backoff 
 likelihood` are all `\t` separated.
 
These models are built using `irlstm`, which should be locally installed in `tools/extras/irstlm`.  
The manual can be found [here](http://hermes.fbk.eu/people/bertoldi/teaching/lab_2010-2011/img/irstlm-manual.pdf) and in the root of this project.

## Building Lexicons and Phones

Beginning with the [CMU `lexicon`](http://svn.code.sf.net/p/cmusphinx/code/trunk/cmudict/cmudict-0.7b), additional dictionary entries can be added or another full `lexicon` can be merged.

Any additional phonemes should also be added to the `phones.txt`.

Scripts exist in `/tools/nextiva_tools/lexicon_pre/` for merging both `lexicon.txt` and `phones.txt`  files: `merge_lexicons.py` and `merge_phones.py`


## Building a Language Model

The language model can be built from any text file(s) **as long as** every word is **also** 
present in the `lexicon.txt` and `lexicon_nosil.txt`.

A workaround can be used where all words **not** in the `lexicon` are replaced with `XYZ` and 
`XYZ` is included in `phones.txt` by adding the following entry:

```
XYZ
```

`XYZ` must also be added to the `lexicon` with the following entry:

```
XYZ XYZ
```

There is required pre-processing of a text file before it can be used to create a language model:

- all uppercase
- all punctuation removed 
- one sentence per line  **Note:** See discussion about `Segmented v. Unsegmented` below for more information on `.` and generating `ngrams`

### Segmented v. Unsegmented

This recipe uses [`irstlm`](http://hlt-mt.fbk.eu/technologies/irstlm) to build the language model
.  A manual with more information on the software can be found [here](http://hermes.fbk.eu/people/bertoldi/teaching/lab_2010-2011/img/irstlm-manual.pdf).

It allows for two options, one which only generates `n-grams` within sentences (`segmented`) and 
one which ignores sentence boundaries when generating `n-grams` (`unsegmented`).

In order to easily generate both types of language models from a single text file, it is 
recommended that the text file be pre-processed to have only sentence on a line.

## The Script(s)

The `/egs/nextiva_recipes/run_all.sh` script will run the entire training process 
from beginning to end.  

### `run_prepare_data.sh`

This script prepares the data for training by preparing the input files into the proper format, resulting in the creation of `nextiva_recipes/data`

**Note:** This can be run with or without testing data

**Note:** The original input files are kept in the following locations:

- `lexicon` (`-x`): `data/local/dict/lexicon.txt`
- `lexicon_nosil` (`-y`): `data/local/dict/lexicon_words.txt`
- `phones` (`-p`): `data/local/dict/nonsilence_phones.txt` and `data/local/dict/silence_phones.txt` and `data/local/dict/optional_silence.txt`
- `transcripts`, (`-r`): `data/train_dir/text` and `data/test_dir/text`
- `language model` (`-l`): `data/local/lm_tg.arpa`

#### Hyper-parameters

- `utils/prepare_lang.sh`
    - `--num-sil-states`, default=`5`, number of states in silence models
    - `--num-nonsil-states`, default=`3`, number of states in non-silence models
    - `--position-dependent-phones`, default=`true`
    - `--reverse`, default=`false`, reverse lexicon
    - `--share-silence-phones`, default=`false`, if `true`, share `pdf`s of all non-silence phones
    - `--sil-prob`, default=`.5`, likelihood of silence
    - `phone-symbol-table`, default=`""`, if not empty use the `phones.txt` as phone symbol table
 
### `run_feature_exctraction.sh`

This script generates `mfcc`s from the audio files present in `nextiva_recipes/data/`.

#### Hyper-parameters

- `steps/make_mfcc.sh`
    - `--mfcc-config`, default=`conf/mfcc.conf`, config file passed to compute-mfcc-feats
    ```
    --sample-frequency=16000 
    --frame-length=25 # the default is 25
    --low-freq=20 # the default.
    --num-ceps=13 # higher than the default which is 12.
    ```
    - `--nj`, default=2, number of parallel jobs to run
    - `--cmd`, default=`utils.run.pl`, how to run jobs
        - other option is `utils/queue.pl <queue opts>`
- `steps/compute_cmvn_stats.sh`
    - `--fake`, if present, generates fake stats that do no normalization
    - `--two-channel`, if present, for two-channel telephone data 
        - there must be no `segments` file
        - there must be a `reco2fil_and_channel` file present
    - `fake-dims`, default=`none`, generates stats that won't cause normalization for these dimensions
        - *e.g.* `13:14:15`

### `run_train_phones.sh`

This script trains and aligns `monophone`s and `triphone`s based on `mffc`s present in `nextiva_recipes/mfcc`.

#### Hyper-parameters

- `steps/train_mono.sh`
    - `--cmd`, default=`utils.run.pl`, how to run jobs
        - other option is `utils/queue.pl <queue opts>`
    - `--nj`, default=2, number of parallel jobs to run
    - `--num_iters`, default=`40`, number of iterations of training
    - `--max_iter_inc`, default=`30`, last iteration to increase Gaussians on
    - `--totgauss`, default=`1000`, total number of target Gaussians
    - `--careful`, default=`false`, ???
    - `--boost_silence`, default=`1.0`, factor by which to boost silence likelihoods in alignments
    - `--realign_iters`, default=`1 2 3 4 5 6 7 8 9 10 12 14 16 18 20 23 26 29 32 35 38`, at which iterations to realign
    - `--stage`, default=`-4`, ???
    - `--power`, default=`0.25`, exponent to determine number of Gaussians from occurrence counts
- `steps/align_si.sh`
    - `--cmd`, default=`utils.run.pl`, how to run jobs
        - other option is `utils/queue.pl <queue opts>`
    - `--nj`, default=2, number of parallel jobs to run
    - `--use_graphs`, default=`false`, use the graphs present in exp/monophones
    - `--scale_opts`, default=`--transition-scale=1.0 --acoustic-scale=0.1 --self-loop-scale=0.1`, ???
    - `--beam`, default=`10`, ???
    - `--retry_beam`, default=`40`, ???
    - `--careful`, default=`false`, ???
    - `--boost_silence`, default=`1.0` factor by which to boost silence likelihoods in alignments
- `train_deltas.sh`
    - `--cmd`, default=`utils.run.pl`, how to run jobs
        - other option is `utils/queue.pl <queue opts>`
    - `--scale_opts`, default=`--transition-scale=1.0 --acoustic-scale=0.1 --self-loop-scale=0.1`, ???
    - `--realign_iters`, default=`10 20 30`, at which iterations to realign
    - `--num_iters`, default=`40`, number of iterations of training
    - `--max_iter_inc`, default=`30`, last iteration to increase Gaussians on
    - `--beam`, default=`10`, ???
    - `--retry_beam`, default=`40`, ???
    - `--careful`, default=`false`, ???
    - `--boost_silence`, default=`1.0` factor by which to boost silence likelihoods in alignments
    - `--power`, default=`0.25`, exponent to determine number of Gaussians from occurrence counts
    - `--cluster_thresh`, default=`-1`, for build-tree control final bottom-up clustering of leaves 

### `run_compile_graph.sh`

This script creates a fully expanded decoding graph (HCLG) that represents the language-model, pronunciation dictionary (lexicon), context-dependency, and HMM structure in our model.  The output is a Finite State Transducer (`FST`) that has word-ids on the output, and pdf-ids on the input (these are indexes that resolve to Gaussian Mixture Models)

#### Hyper-parameters

- `utils/mkgraph.sh`
    - `--mono`, default=`false`, used for `monophone`-only models
    - `--quinphone`, default=`false`, used for `quinphone` models
    - `--reverse`, default=`false`, ???
    - `--transition-scale`, default=`1.0`, ???
    - `--self-loop-scale`, default=`0.1`, ???

### Testing

There are two testing scripts: `run_test.sh` and `run_predict.sh`.

Both of these scripts use `steps/decode.sh`, with the only difference being that `run_test.sh` uses data already processed in `data/test_dir` and `run_predict.sh` can take any audio as input (and then runs through all processing steps for that audio).

#### Hyper-parameters

- `steps/decode.sh`
    - `--cmd`, default=`utils.run.pl`, how to run jobs
        - other option is `utils/queue.pl <queue opts>`
    - `--nj`, default=4, number of parallel jobs to run
    - `--model`, which `final.alimdl` (or `final.mdl`?) file to use, representing the trained model
    - `--max_active`, default=`7000`, ???
    - `--iter`, default=`""`, which iteration (*.e.g.* `35.mdl`?) of model to use
    - `--beam`, default=`13.0`, ???
    - `--lattice_beam`, default=`6.0`, ???
    - `transform-dir`, directory to find `fMLLR` transforms
    - `acwt`, default=`0.08333`, acoustic scale used for lattice generation; only really affects 
    pruning
    - `num_threads`, default=`1`, number of threads to use, if `>1` will use 
    `gmm-latgen-faster-parallel`
    - `scoring-opts`, options for `local/score.sh`
        - `--cmd`, default=`utils.run.pl`, how to run jobs
            - other option is `utils/queue.pl <queue opts>`
        - `--stage`, default=`0`, where to start the scoring script (options: `0|1|2`)
        - `--decode_mbr, default=`true`, Whether to use maximum Bayes risk decoding (confusion 
        network)
        - `--min_lmwt`, default=`9`, minimum LM-weight for lattice re-scoring
        - `--max_lmwt`, default=`11`, maximum LM-weight for lattice re-scoring
        - `--reverse`, default=`false`, whether to score with time-reversed features
        
### `run_clear_all.sh`

This scripts removes all directories that were generated during *any* of the above steps:

- `data/`
- `mfcc/`
- `exp/`

## Common Errors

### language model

If the language model created errors in the graph build, one of these files will be very small:

- `data/lang_test/L_disambig.fst` 
- `data/lang_test/G.fst` 
- `data/lang_test/tmp/LG.fst`

`openfst` has a script that can give information on a `.fst` file: 

```tools/openfst-1.3.4/bin/fstinfo <fst file>```

It will look like this if the `.fst` file is "empty":

```
fst type                                          vector
arc type                                          standard
input symbol table                                none
output symbol table                               none
# of states                                       0
# of arcs                                         0
initial state                                     -1
# of final states                                 0
# of input/output epsilons                        0
# of input epsilons                               0
# of output epsilons                              0
# of accessible states                            0
# of coaccessible states                          0
# of connected states                             0
# of connected components                         0
# of strongly conn components                     0
input matcher                                     y
output matcher                                    y
input lookahead                                   n
output lookahead                                  n
expanded                                          y
mutable                                           y
error                                             n
acceptor                                          y
input deterministic                               y
output deterministic                              y
input/output epsilons                             n
input epsilons                                    n
output epsilons                                   n
input label sorted                                y
output label sorted                               y
weighted                                          n
cyclic                                            n
cyclic at initial state                           n
top sorted                                        y
accessible                                        y
coaccessible                                      y
string                                            y
```

See: https://sourceforge.net/p/kaldi/discussion/1355348/thread/a1dfc5e5/

This can happen for any number of reasons, but two that have been identified are below.

```FATAL: FstCompiler: Symbol "NRA" is not mapped to any integer arc ilabel, symbol table = data/lang_test_tg/words.```

This means there is a word in the `language model` that is *not* in the `lexicon`:

```ERROR (arpa2fst:Read():arpa-file-parser.cc:220) line 19489 [\2-grams:]: header said there would be 19477 n-grams of order 1, but we saw more already.```
