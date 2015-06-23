
KERNELVER := $(shell uname -r)
EXTRA_CFLAGS += -O2 
EXTRA_CFLAGS += -I $(PWD)/../../common/board

ifneq ($(KERNELRELEASE),)

pexdrv-objs := memory.o event.o dmachan.o ioctlrw.o pexmodule.o pexproc.o hardware.o
obj-m := pexdrv.o

else

KERNELDIR ?= /lib/modules/$(shell uname -r)/build

PWD := $(shell pwd)

modules:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) EXTRA_CFLAGS="$(EXTRA_CFLAGS)"

endif

distclean:
	rm -rf *.o *~ core .depend .*.cmd *.ko *.mod.c .tmp_versions *.bak .*.cache *.d
clean:
	rm -rf *.o *~ core .depend .*.cmd *.ko *.mod.c .tmp_versions *.bak .*.cache *.d *.markers *.symvers *.order

depend .depend dep:
	$(CC) $(EXTRA_CFLAGS) -M *.c > .depend

ifeq (.depend, $(wildcard .depend))
include .depend
endif

install:
	./insert
