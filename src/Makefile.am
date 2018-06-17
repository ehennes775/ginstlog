RESOURCES_FILE = ginstlog.gresource.xml

AM_CPPFLAGS = $(DEPS_CFLAGS) -DIMAGE_DIR=\"$(imgdir)\" -DPKGDATADIR=\"$(pkgdatadir)\" -include config.h
AM_VALAFLAGS = --target-glib=2.38 --pkg gee-0.8 --pkg gtk+-3.0 --pkg libxml-2.0 --pkg posix --gresources=$(RESOURCES_FILE)

GLIB_COMPILE_RESOURCES = glib-compile-resources

RESOURCE_FILES = ginstlog.gresource.c

$(RESOURCE_FILES) : $(RESOURCES_FILE) $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies $(RESOURCES_FILE))
	$(AM_V_GEN) $(GLIB_COMPILE_RESOURCES) --target=$@ --generate-source $<

BUILT_SOURCES = \
	$(RESOURCE_FILES)

bin_PROGRAMS = ginstlog

ginstlog_SOURCES = \
	Channel.vala \
	Configuration.vala \
	ConfigurationError.vala \
	CommunicationError.vala \
	ErrorDialog.vala \
	ExtechSdl200Worker.vala \
	FourChannelInstrumentWidget.vala \
	HumidityTempMeter314BWorker.vala \
	Instrument.vala \
	InstrumentError.vala \
	InstrumentFactory.vala \
	InstrumentFactoryLookup.vala \
	InstrumentWorker.vala \
	InstrumentWorkerFactory.vala \
	InternalError.vala \
	MainWindow.vala \
	Measurement.vala \
	MeasurementFailure.vala \
	Program.vala \
	RelativeHumidity.vala \
	SerialDevice.vala \
	SerialDeviceFactory.vala \
	SerialDeviceFactoryLookup.vala \
	TcpSerialServer.vala \
	Temperature.vala \
	TemperatureUnits.vala \
	ThermocoupleType.vala \
	Thermometer.vala \
	Thermometer301Worker.vala \
	Thermometer304Worker.vala \
	Thermometer306Worker.vala \
	Thermometer3xxWorker.vala \
	ThermometerFactory.vala \
	ThermometerWidget.vala \
	TripleThermometerWidget.vala \
	TtySerialDevice.vala \
	TtySerialDeviceFactory.vala \
	XmlUtility.vala \
	$(BUILT_SOURCES)

ginstlog_LDADD = -lm $(DEPS_LIBS)
