# RIOXX2 Plugin for EPrints #

The RIOXX2 plugin for EPrints allows you to:

* Capture additional metadata required by the RIOXX 2.0 Application Profile (http://rioxx.net/v2-0-final/)
* Measure compliance across your EPrints repository
* Expose RIOXX 2.0 compliant XML records via OAI-PMH, for consumption by Funders and Governing bodies

The 1.0.x series of releases is funded by Jisc (http://jisc.ac.uk/)

## Information for Repository Administrators ##

The plugin is available for installation via the EPrints Bazaar.

Please see the User Guide for further details of how the plugin will work in your repository.

## Information for Repository Developers ##

Please see the Configuration Guide for details of how to configure the plugin to work most effectively with your repository.

### How to contribute ###

```
cd /opt/eprints3/lib/epm
git clone git@github.com:yourfork/rioxx2.git
cd /opt/eprints3
tools/epm link_lib rioxx2
tools/epm enable foo rioxx2
tools/epm link_cfg foo rioxx2
```

This should give you an environment where you can test the plugin, modify the code and easily commit changes (plugin code in /opt/eprints3/lib and /opt/eprints3/archives/foo/ is symlinked to the git clone in /opt/eprints3/lib/epm).
