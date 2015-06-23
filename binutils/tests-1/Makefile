#
# Makefile for as/ld tests
#

BUILD = ../../build

DIRS = H16 L16 R16 R26 W32

.PHONY:		all clean

all:
		for i in $(DIRS) ; do \
		  $(MAKE) -C $$i all ; \
		done

clean:
		for i in $(DIRS) ; do \
		  $(MAKE) -C $$i clean ; \
		done
		rm -f *~
