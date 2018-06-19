AC_INIT([ginstlog],[0.0],[],[ginstlog],[https://github.com/ehennes775/ginstlog])
AC_PREREQ([2.64])

AC_CONFIG_HEADERS([config.h])
AM_INIT_AUTOMAKE([foreign subdir-objects])
AC_PROG_CC
AM_PROG_VALAC([0.25.1])
AC_SUBST(PACKAGE_NAME)

AC_CHECK_PROG([XSLTPROC],[xsltproc],[xsltproc])

AC_CONFIG_FILES([
	Makefile
	docs/InstrumentTableToMarkdown.xslt
	docs/Makefile
	src/Makefile
	])

PKG_CHECK_MODULES([DEPS], [
	gee-0.8  >= 0.6.4
	glib-2.0 >= 2.38.1
	gtk+-3.0 >= 3.8.6
	libxml-2.0 >= 2.7.8
	])

AC_OUTPUT
