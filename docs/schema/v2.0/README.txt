$ cd /opt/eprints3 
$ bin/export foo archive RIOXX2 123 --single > test.xml
$ cd lib/epm/rioxx2/docs/schema/v2.0
$ wget http://dublincore.org/schemas/xmls/qdc/dc.xsd
$ wget http://dublincore.org/schemas/xmls/qdc/dcterms.xsd
$ wget http://dublincore.org/schemas/xmls/qdc/2008/02/11/dcmitype.xsd
$ xmllint --noout --schema rioxx.xsd test.xml
