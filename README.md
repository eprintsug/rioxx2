# RIOXX2 Plugin for EPrints #

The RIOXX2 plugin for EPrints allows you to:

* Capture additional metadata required by the RIOXX 2.0 Application Profile (http://rioxx.net/v2-0-beta-1/)
* Measure compliance across your EPrints repository
* Expose RIOXX 2.0 compliant XML records via OAI-PMH, for consumption by Funders and Governing bodies

The v1.0 Early Adopters release was funded by Jisc (http://jisc.ac.uk/)

## information for Repository Administrators ##

Once early adoption testing is complete, the plugin will be available for installation via the EPrints Bazaar.

In the meantime, please see the User Guide for further details of how the plugin will work in your repository.

## Information for Developers ##

```
cd /opt/eprints3/lib/epm
git clone git@github.com:eprintsug/rioxx2.git
cd /opt/eprints3
git clone git@github.com:eprintsug/gitaar.git
gitaar/gitaar myrepo rioxx2
tools/epm link_lib rioxx2
tools/epm enable myrepo rioxx2
tools/epm link_cfg myrepo rioxx2
```

This should give you an environment where you can test the plugin, modify the code and easily commit changes (plugin code in /opt/eprints3/lib and /opt/eprints3/archives/myrepo/ is symlinked to the git checkout in /opt/eprints3/lib/epm)
