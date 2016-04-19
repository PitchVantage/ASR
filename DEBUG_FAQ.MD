# Debug FAQ

This file will contain an ongoing list of the debugging steps that we have learned.

##Table of Contents


- [Language Model](#language_model) <!---a dash and a space will make bullet-->
    - [Question One](#what_does_my_first_question_look_like?) <!---indent four spaces for each nested level-->
- [Switching Branches](#switching_branches)
	- [Re-compiling C Code](#re-compiling_C_Code)

## Language Model <!---two hash marks for a topic-->

#### What does my first question look like? <!---four hash marks for a question-->

Here's where I put the answer.

#### What is the second question?

It goes here.

## Acoustic

## Switching Branches

#### Re-compiling C Code

After switching branches in Github, use these steps to re-compile the C Code:
- go to /src and open INSTALL
    - ```./configure```
    - ```make depend -j 4```		*for multi-cores
    - ```make -j 4```


