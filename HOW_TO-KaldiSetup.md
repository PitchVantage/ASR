KALDI - SETUP
=============

GITHUB
-------

1. Clone the repository 
```git clone https://github.com/PitchVantage/ASR.git```

2. Checkout branch `pitchKaldi`


INSTALL DEPENDENCIES
----------

*Note: many of these are in the `.gitignore` file, most likely because they have local information.  So *anyone* who is trying to use the versioned kaldi that we have, *must* install these dependencies

1. go to /tools and open INSTALL

    - ```extras/check_dependencies.sh```
    - It will identify any dependencies that are uninstalled
        - Note: These can all be installed via `homebrew` if on `Mac OS`
    - ```make -j 4```		*for multi-cores
	    - ```make```			*for one core

2. go to /src and open INSTALL

    - ```./configure```
        - ```/configure --shared``` must be used if interested in using `python` [file viewer](https://github.com/janchorowski/kaldi-python)
    - ```make depend -j 4```		*for multi-cores
    - ```make -j 4```

3. go to `tools/extras/` and run `install_irstlm.sh`

UPDATING GITHUB PROJECT
-------------------------

- always use `pitchKaldi` branch.
- ```git push origin pitchKaldi```
