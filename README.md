# README #

### Getting started ###


```
#!bash

cd /opt/eprints3/lib/epm
git clone git@bitbucket.org:drsltd/rioxx2.git
cd /opt/eprints3
tools/epm link_lib rioxx2
tools/epm enable ARCHIVEID rioxx2 
tools/epm link_cfg ARCHIVEID rioxx2 --force
```


### Refreshing ###

* Re-run link_lib if adding or removing a file in lib/epm/rioxx2/lib
* Re-run link_cfg if adding or removing a file in lib/epm/rioxx2/cfg
* If lib/epm/rioxx2/lib/workflows/eprint/rioxx2.xml changes, the following steps are required:


```
#!bash

tools/epm disable ARCHIVEID rioxx2 # remove rioxx2 stage from workflows/eprint/default.xml
tools/epm enable ARCHIVEID rioxx2 # adds the modified rioxx2 stage back in
tools/epm link_cfg ARCHIVEID rioxx2 --force
```
