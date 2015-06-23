#
# Makefile for divtest ROM
#

BUILD = ../../build

.PHONY:		all install run clean

all:		divtest.exo

install:	divtest.exo

divtest.exo:	divtest.bin
		$(BUILD)/bin/bin2exo -S2 0 divtest.bin divtest.exo

divtest.bin:	divtest.o
		$(BUILD)/bin/ld -h -rc 0xE0000000 -o divtest.bin divtest.o

divtest.o:	divtest.s
		$(BUILD)/bin/as -o divtest.o divtest.s

divtest.s:	mkdivtest
		./mkdivtest > divtest.s

mkdivtest:	mkdivtest.c
		gcc -g -Wall -o mkdivtest mkdivtest.c

run:		divtest.bin
		$(BUILD)/bin/sim -i -s 1 -t 0 -r divtest.bin

clean:
		rm -f *~ mkdivtest divtest.s divtest.o
		rm -f divtest.bin divtest.exo
