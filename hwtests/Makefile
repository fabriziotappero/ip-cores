#
# Makefile for building hardware test ROMs
#

BUILD = ../build

DIRS = serial looptest ldtest memtest1 memtest2 shtest brtest \
       tmrtest multest divtest remtest sregtest tlbtest irqtest \
       xcptest dsptest kbdtest jalrtest

.PHONY:		all install clean

all:
		for i in $(DIRS) ; do \
		  $(MAKE) -C $$i all ; \
		done

install:
		for i in $(DIRS) ; do \
		  $(MAKE) -C $$i install ; \
		done

clean:
		for i in $(DIRS) ; do \
		  $(MAKE) -C $$i clean ; \
		done
		rm -f *~
