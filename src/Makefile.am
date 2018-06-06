RESOURCES_FILE = ginstlog.gresource.xml

AM_CPPFLAGS = $(DEPS_CFLAGS) -DIMAGE_DIR=\"$(imgdir)\" -DPKGDATADIR=\"$(pkgdatadir)\" -include config.h
AM_VALAFLAGS = --target-glib=2.38 --pkg gee-0.8 --pkg gtk+-3.0 --pkg libxml-2.0 --pkg posix --gresources=$(RESOURCES_FILE)

GLIB_COMPILE_RESOURCES = glib-compile-resources

BUILT_SOURCES = ginstlog.gresource.c

$(BUILT_SOURCES) : $(RESOURCES_FILE) $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies $(RESOURCES_FILE))
	$(AM_V_GEN) $(GLIB_COMPILE_RESOURCES) --target=$@ --generate-source $<

bin_PROGRAMS = ginstlog

ginstlog_SOURCES = \
	Instrument.vala \
	InstrumentError.vala \
	MainWindow.vala \
	Measurement.vala \
	Program.vala \
	Temperature.vala \
	TemperatureUnits.vala \
	Thermometer.vala \
	ThermometerWidget.vala \
	$(BUILT_SOURCES)

ginstlog_LDADD = -lm $(DEPS_LIBS)
