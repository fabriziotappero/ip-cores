#
# Makefile for basic disk tools
#

BUILD = ../../build

DIRS = mkdisk mkmboot mkpart shpart wrpart fs-EOS32 fs-NetBSD fs-Linux

.PHONY:		all install clean

all:
		for i in $(DIRS) ; do \
		  $(MAKE) -C $$i all ; \
		done

install:
		for i in $(DIRS) ; do \
		  $(MAKE) -C $$i install ; \
		done
		mkdir -p $(BUILD)/run
		cp Makefile.run $(BUILD)/run/Makefile

clean:
		for i in $(DIRS) ; do \
		  $(MAKE) -C $$i clean ; \
		done
		rm -f *~
