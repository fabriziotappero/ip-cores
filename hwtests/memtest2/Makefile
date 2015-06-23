#
# Makefile for memtest2 ROM
#

BUILD = ../../build

.PHONY:		all install run clean

all:		memtest2.exo

install:	memtest2.exo

memtest2.exo:	memtest2.bin
		$(BUILD)/bin/bin2exo -S2 0 memtest2.bin memtest2.exo

memtest2.bin:	memtest2.o
		$(BUILD)/bin/ld -h -rc 0xE0000000 \
		  -o memtest2.bin memtest2.o

memtest2.o:	memtest2.s
		$(BUILD)/bin/as -o memtest2.o memtest2.s

run:		memtest2.bin
		$(BUILD)/bin/sim -i -s 1 -t 0 -r memtest2.bin

clean:
		rm -f *~ memtest2.o memtest2.bin memtest2.exo
