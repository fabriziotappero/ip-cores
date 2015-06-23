ifneq ($(KERNELRELEASE),)
    obj-m	:= fpga_l3_fade.o    
else
KDIR	:= /lib/modules/$(shell uname -r)/build
PWD	:= $(shell pwd)
default:
	$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) modules
	gcc -O2 -o receiver2 receiver2.c
endif