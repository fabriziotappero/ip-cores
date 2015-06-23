ifneq ($(KERNELRELEASE),)
include Kbuild
else
# Normal Makefile
KERNELDIR := /lib/modules/`uname -r`/build

modules::
	$(MAKE) -C $(KERNELDIR) M=`pwd` $@

clean:
	$(MAKE) -C $(KERNELDIR) M=`pwd` $@
	-rm -f Module.symvers

endif

install:
	-rmmod mod_pci_7seg
	sleep 1
	insmod ./mod_pci_7seg.ko
	-mknod /dev/fpga c 100 0
