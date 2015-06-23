#
# Makefile to build the master bootstrap (boot manager)
#

BUILD = ../../../../build

all:		mboot.bin

mboot.bin:	c0.o mboot.o biolib.o c1.o
		$(BUILD)/bin/ld -h -rc 0xC0011000 -o mboot.bin \
		  c0.o mboot.o biolib.o c1.o

c0.o:		c0.s
		$(BUILD)/bin/as -o c0.o c0.s

mboot.o:	mboot.c
		$(BUILD)/bin/lcc -A -c -o mboot.o mboot.c

biolib.o:	biolib.s
		$(BUILD)/bin/as -o biolib.o biolib.s

c1.o:		c1.s
		$(BUILD)/bin/as -o c1.o c1.s

clean:
		rm -f *~ c0.o mboot.o biolib.o c1.o mboot.bin
