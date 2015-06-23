#
# Makefile to synthesize the project for different boards
#

DIRS = XESS-XST-3S1000 Digilent-S3E-500

all:
		for i in $(DIRS) ; do \
		  $(MAKE) -C $$i all ; \
		done

clean:
		for i in $(DIRS) ; do \
		  $(MAKE) -C $$i clean ; \
		done
		rm -f *~
