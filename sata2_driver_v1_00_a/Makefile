LINUX = ../linux-2.6-xlnx
DRIVER_NAME=sata

# If KERNELRELEASE is defined, we've been invoked from the
# kernel build system and can use its language.
ifneq ($(KERNELRELEASE),)
	obj-m := $(DRIVER_NAME).o
	$(DRIVER_NAME)-objs := $(DRIVER_NAME)_drv.o 

# Otherwise we were called directly from the command
# line; invoke the kernel build system.
else
	KERNELDIR ?= $(LINUX)
	PWD := $(shell pwd)

default:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) ARCH=microblaze CROSS_COMPILE=microblaze-unknown-linux-gnu- modules
endif

clean:
	rm -rf *.ko *.o *~ modules.order Module.symvers  *.mod.c .tmp_versions .$(DRIVER_NAME)*

