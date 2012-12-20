# $Id: Makefile,v 1.19 2012/08/21 17:24:07 nanard Exp $
# This Makefile is designed for use with GNU make
# libnatpmp
# (c) 2007-2011 Thomas Bernard
# http://miniupnp.free.fr/libnatpmp.html

OS = $(shell uname -s)
CC = gcc
INSTALL = install
VERSION = $(shell cat VERSION)

ifeq ($(OS), Darwin)
JARSUFFIX=mac
endif
ifeq ($(OS), Linux)
JARSUFFIX=linux
endif
ifneq (,$(findstring WIN,$(OS)))
JARSUFFIX=win32
endif

# APIVERSION is used in soname
APIVERSION = 1
#LDFLAGS = -Wl,--no-undefined
CFLAGS = -Os
#CFLAGS = -g -O0
CFLAGS += -fPIC
CFLAGS += -Wall
CFLAGS += -Wextra
CFLAGS += -DENABLE_STRNATPMPERR

LIBOBJS = natpmp.o getgateway.o

OBJS = $(LIBOBJS) testgetgateway.o natpmpc.o

STATICLIB = libnatpmp.a
ifeq ($(OS), Darwin)
  SHAREDLIB = libnatpmp.dylib
  SONAME = $(basename $(SHAREDLIB)).$(APIVERSION).dylib
  CFLAGS := -DMACOSX -D_DARWIN_C_SOURCE $(CFLAGS)
else
  SHAREDLIB = libnatpmp.so
  SONAME = $(SHAREDLIB).$(APIVERSION)
endif

HEADERS = natpmp.h

EXECUTABLES = testgetgateway natpmpc-shared natpmpc-static

INSTALLPREFIX ?= $(PREFIX)/usr
INSTALLDIRINC = $(INSTALLPREFIX)/include
INSTALLDIRLIB = $(INSTALLPREFIX)/lib
INSTALLDIRBIN = $(INSTALLPREFIX)/bin

JAVA = java
# see http://code.google.com/p/jnaerator/
JNAERATOR = jnaerator-0.9.7.jar
JNAERATORBASEURL = http://jnaerator.googlecode.com/files/


.PHONY:	all clean depend install cleaninstall installpythonmodule

all: $(STATICLIB) $(SHAREDLIB) $(EXECUTABLES)

pythonmodule: $(STATICLIB) libnatpmpmodule.c setup.py
	python setup.py build
	touch $@

installpythonmodule: pythonmodule
	python setup.py install

clean:
	$(RM) $(OBJS) $(EXECUTABLES) $(STATICLIB) $(SHAREDLIB)
	$(RM) pythonmodule
	$(RM) -r build/ dist/
	$(RM) _jnaerator.* java/natpmp_$(OS).jar

depend:
	makedepend -f$(MAKEFILE_LIST) -Y $(OBJS:.o=.c) 2>/dev/null

install:	$(HEADERS) $(STATICLIB) $(SHAREDLIB) natpmpc-shared
	$(INSTALL) -d $(INSTALLDIRINC)
	$(INSTALL) -m 644 $(HEADERS) $(INSTALLDIRINC)
	$(INSTALL) -d $(INSTALLDIRLIB)
	$(INSTALL) -m 644 $(STATICLIB) $(INSTALLDIRLIB)
	$(INSTALL) -m 644 $(SHAREDLIB) $(INSTALLDIRLIB)/$(SONAME)
	$(INSTALL) -d $(INSTALLDIRBIN)
	$(INSTALL) -m 755 natpmpc-shared $(INSTALLDIRBIN)/natpmpc
	ln -s -f $(SONAME) $(INSTALLDIRLIB)/$(SHAREDLIB)

jnaerator-0.9.8-shaded.jar:
	wget $(JNAERATORBASEURL)/$@ || curl -o $@ $(JNAERATORBASEURL)/$@

jnaerator-0.9.7.jar:
	wget $(JNAERATORBASEURL)/$@ || curl -o $@ $(JNAERATORBASEURL)/$@

jnaerator-0.9.3.jar:
	wget $(JNAERATORBASEURL)/$@ || curl -o $@ $(JNAERATORBASEURL)/$@

jar: $(SHAREDLIBRARY)  $(JNAERATOR)
	$(JAVA) -jar $(JNAERATOR) -library natpmp \
	natpmp.h declspec.h wingettimeofday.h getgateway.h \
	$(SHAREDLIBRARY) -package fr.free.natpmp -o . \
	-jar java/natpmp_$(JARSUFFIX).jar -v

mvn_install:
	mvn install:install-file -Dfile=java/natpmp_$(JARSUFFIX).jar \
	 -DgroupId=com.github \
	 -DartifactId=natpmp \
	 -Dversion=$(VERSION) \
	 -Dpackaging=jar \
	 -Dclassifier=$(JARSUFFIX) \
	 -DgeneratePom=true \
	 -DcreateChecksum=true

cleaninstall:
	$(RM) $(addprefix $(INSTALLDIRINC), $(HEADERS))
	$(RM) $(INSTALLDIRLIB)/$(SONAME)
	$(RM) $(INSTALLDIRLIB)/$(SHAREDLIB)
	$(RM) $(INSTALLDIRLIB)/$(STATICLIB)

testgetgateway:	testgetgateway.o getgateway.o

natpmpc-static:	natpmpc.o $(STATICLIB)
	$(CC) $(LDFLAGS) -o $@ $^

natpmpc-shared:	natpmpc.o $(SHAREDLIB)
	$(CC) $(LDFLAGS) -o $@ $^

$(STATICLIB):	$(LIBOBJS)
	$(AR) crs $@ $?

$(SHAREDLIB):	$(LIBOBJS)
ifeq ($(OS), Darwin)
	$(CC) -dynamiclib -Wl,-install_name,$(SONAME) -o $@ $^
else
	$(CC) -shared -Wl,-soname,$(SONAME) -o $@ $^
endif

# DO NOT DELETE

natpmp.o: natpmp.h getgateway.h declspec.h
getgateway.o: getgateway.h declspec.h
testgetgateway.o: getgateway.h declspec.h
natpmpc.o: natpmp.h
