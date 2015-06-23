ifneq ($(KERNELRELEASE),)
    obj-m	:= fpga_l3_fade.o    
else
KDIR	:= /lib/modules/$(shell uname -r)/build
PWD	:= $(shell pwd)
default:
	$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) modules
	gcc -O3 -o receiver2t_cmd receiver2t_cmd.c -lpthread
	gcc -O3 -o receiver2t receiver2t.c -lpthread
	gcc -O3 -o receiver3 receiver3.c
endif
