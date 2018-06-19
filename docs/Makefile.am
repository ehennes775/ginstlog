BUILT_SOURCES = Instruments.md

Instruments.md : ../src/InstrumentTable.xml InstrumentTableToMarkdown.xslt
	$(XSLTPROC) --output $@ InstrumentTableToMarkdown.xslt ../src/InstrumentTable.xml
