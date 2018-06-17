BUILT_SOURCES = Instruments.md

Instruments.md : ../src/InstrumentTable.xml ../src/InstrumentTableToMarkdown.xslt
	xsltproc --output Instruments.md ../src/InstrumentTableToMarkdown.xslt ../src/InstrumentTable.xml
