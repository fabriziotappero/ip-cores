#
# Makefile for LogicProbe project
#

VERSION = 1.1

DIRS = src tst

all:
		for i in $(DIRS) ; do \
		  $(MAKE) -C $$i all ; \
		done

clean:
		for i in $(DIRS) ; do \
		  $(MAKE) -C $$i clean ; \
		done
		rm -f *~

dist:		clean
		(cd .. ; \
		 tar --exclude-vcs -cvf \
		   LogicProbe-$(VERSION).tar \
		   LogicProbe-$(VERSION)/* ; \
		 gzip -f LogicProbe-$(VERSION).tar)
