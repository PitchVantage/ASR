KALDI - SETUP
=============

GITHUB
-------

1. Clone the repository [http://kaldi.sourceforge.net/tutorial_git.html]
```git clone https://github.com/kaldi-asr/kaldi.git --branch master --single-branch --origin golden```

2. Immediately setup a branch for our use
	*prevents pushing to the master
```git checkout -b pitchVantageKALDI```


INSTALL DEPENDENCIES
----------

*Note: many of these are in the `.gitignore` file, most likely because they have local information.  So *anyone* who is trying to use the versioned kaldi that we have, *must* install these dependencies

1. go to /tools and open INSTALL

    - ```extras/check_dependencies.sh```
    - do what it says
    - ```make -j 4```		*for multi-cores
	OR
	```make```			*for one core

2. go to /src and open INSTALL

    - ```./configure```
    - ```make depend -j 4```		*for multi-cores
    - ```make -j 4```

3. go to `tools/extras/` and run `install_irstlm.sh`

UPDATING GITHUB PROJECT
-------------------------

- always use `pitchKaldi` branch.
- ```git push origin pitchKaldi```
