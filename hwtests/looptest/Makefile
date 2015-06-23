#
# Makefile for looptest ROM
#

BUILD = ../../build

.PHONY:		all install run clean

all:		looptest.exo

install:	looptest.exo

looptest.exo:	looptest.bin
		$(BUILD)/bin/bin2exo -S2 0 looptest.bin looptest.exo

looptest.bin:	looptest.o
		$(BUILD)/bin/ld -h -rc 0xE0000000 \
		  -o looptest.bin looptest.o

looptest.o:	looptest.s
		$(BUILD)/bin/as -o looptest.o looptest.s

looptest.s:	mklooptest
		./mklooptest > looptest.s

mklooptest:	mklooptest.c
		gcc -g -Wall -o mklooptest mklooptest.c

run:		looptest.bin
		$(BUILD)/bin/sim -i -s 1 -t 0 -r looptest.bin

clean:
		rm -f *~ mklooptest looptest.s looptest.o
		rm -f looptest.bin looptest.exo
