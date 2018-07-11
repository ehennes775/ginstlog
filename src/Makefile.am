RESOURCES_FILE = ginstlog.gresource.xml

AM_CPPFLAGS = $(DEPS_CFLAGS) -DIMAGE_DIR=\"$(imgdir)\" -DPKGDATADIR=\"$(pkgdatadir)\" -include config.h
AM_VALAFLAGS = --target-glib=2.38 --pkg gee-0.8 --pkg gtk+-3.0 --pkg libxml-2.0 --pkg linux --pkg posix --gresources=$(RESOURCES_FILE)

GLIB_COMPILE_RESOURCES = glib-compile-resources

RESOURCE_FILES = ginstlog.gresource.c

$(RESOURCE_FILES) : $(RESOURCES_FILE) $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies $(RESOURCES_FILE))
	$(AM_V_GEN) $(GLIB_COMPILE_RESOURCES) --target=$@ --generate-source $<

BUILT_SOURCES = \
	CommunicationError.vala \
	$(RESOURCE_FILES)

bin_PROGRAMS = ginstlog

ginstlog_SOURCES = \
	Ea15/Ea15Worker.vala \
	Ea15/Ea15WorkerFactory.vala \
	Ea15/EaWorker.vala \
	Ea15/ReadMeasurements.vala \
	Ea15/ReadMeasurementsEa15.vala \
	Logging/CancelEntry.vala \
	Logging/CsvColumn.vala \
	Logging/CsvTimeColumn.vala \
	Logging/CsvMeasurementColumn.vala \
	Logging/CsvWriter.vala \
	Logging/CsvWriterFactory.vala \
	Logging/Entry.vala \
	Logging/FailureEntry.vala \
	Logging/FileMode.vala \
	Logging/Logger.vala \
	Logging/LoggerFactory.vala \
	Logging/LoggerWorker.vala \
	Logging/SuccessEntry.vala \
	Logging/TimeoutTrigger.vala \
	Logging/Trigger.vala \
	Logging/Writer.vala \
	Series300/Model301Worker.vala \
	Series300/Model301WorkerFactory.vala \
	Series300/Model304Worker.vala \
	Series300/Model306Worker.vala \
	Series300/Model306WorkerFactory.vala \
	Series300/Model309Worker.vala \
	Series300/Model309WorkerFactory.vala \
	Series300/Model314BWorker.vala \
	Series300/Model314WorkerFactory.vala \
	Series300/ReadMeasurements.vala \
	Series300/ReadMeasurements8.vala \
	Series300/ReadMeasurements10.vala \
	Series300/ReadMeasurements45.vala \
	Series300/Series300Worker.vala \
	Series407/ReadMeasurements.vala \
	Series407/ReadMeasurementsSdl200.vala \
	Series407/Series407Worker.vala \
	Series407/Series407WorkerFactory.vala \
	Channel.vala \
	Configuration.vala \
	ErrorDialog.vala \
	FourChannelInstrumentWidget.vala \
	Instrument.vala \
	InstrumentError.vala \
	InstrumentFactory.vala \
	InstrumentFactoryLookup.vala \
	InstrumentWorker.vala \
	InstrumentWorkerFactory.vala \
	InternalError.vala \
	LoggerWidget.vala \
	MainWindow.vala \
	Measurement.vala \
	MeasurementFailure.vala \
	Program.vala \
	RelativeHumidity.vala \
	SerialDevice.vala \
	SerialDeviceFactory.vala \
	SerialDeviceFactoryLookup.vala \
	TcpSerialServer.vala \
	TcpSerialServerFactory.vala \
	Temperature.vala \
	TemperatureUnits.vala \
	ThermocoupleType.vala \
	Thermometer.vala \
	ThermometerFactory.vala \
	ThermometerWidget.vala \
	TripleThermometerWidget.vala \
	TtySerialDevice.vala \
	TtySerialDeviceFactory.vala \
	XmlUtility.vala \
	$(BUILT_SOURCES)

ginstlog_LDADD = -lm $(DEPS_LIBS)


CommunicationError.vala : ErrorTable.xml ErrorTableToVala.xslt
	$(XSLTPROC) --output $@ ErrorTableToVala.xslt ErrorTable.xml
