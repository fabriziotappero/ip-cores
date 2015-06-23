#
# Makefile to build the simulation test programs and
# synthesize the project for different boards
#

DIRS = sim-c sim-v boards

all:
		for i in $(DIRS) ; do \
		  $(MAKE) -C $$i all ; \
		done

clean:
		for i in $(DIRS) ; do \
		  $(MAKE) -C $$i clean ; \
		done
		rm -f *~
