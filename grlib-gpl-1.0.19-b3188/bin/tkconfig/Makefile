
CC=gcc
CFLAGS=-g

all: lconfig.tk

xconfig: lconfig.tk
	wish -f lconfig.tk; echo xconfig exited with code $$?; 

wconfig: lconfig.tk
	cygwish80 -f lconfig.tk

dep: mkdevice lconfig.tk
	./mkdevice < .config
	-cp device.vhd device.v ../leon/

tkparse: tkparse.o tkcond.o tkgen.o
	$(CC) tkparse.o tkcond.o tkgen.o -o tkparse

mkdevice: mkdevice.o
	$(CC) mkdevice.o -o mkdevice

lconfig.tk: leon.tk header.tk tail.tk
	cat header.tk leon.tk tail.tk > lconfig.tk
	chmod a+x lconfig.tk

leon.tk : config.in tkparse
	./tkparse < config.in > leon.tk

clean:
	-rm lconfig.tk leon.tk test.tk *.o tkparse mkdevice *.exe device.vhd device.v 

dist-clean: clean
	-rm .config .config.old
	cp defconfig .config
