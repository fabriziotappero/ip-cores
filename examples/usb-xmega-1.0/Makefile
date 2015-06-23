DIRS=flashdemo flashbench nvmtest ucecho

.PHONY: default all clean distclean avr avrclean avrdistclean

default: 
	@echo "This makefile is intended to clean up the project or to build all examples in this subdirectory"
	@echo "Usage: make all | clean | distclean"

all: 
	set -e; for i in $(DIRS); do make -C $$i all; done

clean: 
	set -e; for i in $(DIRS); do make -C $$i clean; done

distclean:
	set -e; for i in $(DIRS); do make -C $$i distclean; done

avr: 
	set -e; for i in $(DIRS); do make -C $$i avr; done

avrclean: 
	set -e; for i in $(DIRS); do make -C $$i avrclean; done

avrdistclean: 
	set -e; for i in $(DIRS); do make -C $$i avrdistclean; done
