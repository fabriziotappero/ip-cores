#
# Makefile for building a fake NetBSD partition
#

BUILD = ../../../build

DIRS = mkpboot

.PHONY:		all install clean

all:
		for i in $(DIRS) ; do \
		  $(MAKE) -C $$i all ; \
		done

install:
		for i in $(DIRS) ; do \
		  $(MAKE) -C $$i install ; \
		done
		mkdir -p $(BUILD)/run/fs-NetBSD
		cp Makefile.run $(BUILD)/run/fs-NetBSD/Makefile

clean:
		for i in $(DIRS) ; do \
		  $(MAKE) -C $$i clean ; \
		done
		rm -f *~
