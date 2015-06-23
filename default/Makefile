DIRS=usb-fpga-1.15 usb-fpga-1.15y usb-fpga-2.16 usb-fpga-2.13

.PHONY: default all clean distclean

default: 
	@echo "This makefile is intended to clean up the project or to build all examples"
	@echo "Usage: make all | clean | distclean"

all: 
	set -e; for i in $(DIRS); do make -C $$i all; done

clean: 
	set -e; for i in $(DIRS); do make -C $$i clean; done

distclean:
	set -e; for i in $(DIRS); do make -C $$i distclean; done
