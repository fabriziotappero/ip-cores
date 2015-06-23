#
# Makefile for multest ROM
#

BUILD = ../../build

.PHONY:		all install run clean

all:		multest.exo

install:	multest.exo

multest.exo:	multest.bin
		$(BUILD)/bin/bin2exo -S2 0 multest.bin multest.exo

multest.bin:	multest.o
		$(BUILD)/bin/ld -h -rc 0xE0000000 -o multest.bin multest.o

multest.o:	multest.s
		$(BUILD)/bin/as -o multest.o multest.s

multest.s:	mkmultest
		./mkmultest > multest.s

mkmultest:	mkmultest.c
		gcc -g -Wall -o mkmultest mkmultest.c

run:		multest.bin
		$(BUILD)/bin/sim -i -s 1 -t 0 -r multest.bin

clean:
		rm -f *~ mkmultest multest.s multest.o
		rm -f multest.bin multest.exo
