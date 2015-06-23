LINUX_SRC = /usr/src/linux

spartan_fb.o: spartan_fb.c
	gcc -D__KERNEL__ -DMODULE -I$(LINUX_SRC)/include -I. -O2 -c -o spartan_fb.o spartan_fb.c

install:
	insmod spartan_fb.o

unisntall:
	rmmod spartan_fb

