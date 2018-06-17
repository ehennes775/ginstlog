BUILT_SOURCES = Instruments.md

Instruments.md : ../src/InstrumentTable.xml ../src/InstrumentTableToMarkdown.xslt
	$(XSLTPROC) --output $@ ../src/InstrumentTableToMarkdown.xslt ../src/InstrumentTable.xml
