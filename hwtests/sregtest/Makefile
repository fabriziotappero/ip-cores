#
# Makefile for sregtest ROM
#

BUILD = ../../build

.PHONY:		all install run clean

all:		sregtest.exo

install:	sregtest.exo

sregtest.exo:	sregtest.bin
		$(BUILD)/bin/bin2exo -S2 0 sregtest.bin sregtest.exo

sregtest.bin:	sregtest.o
		$(BUILD)/bin/ld -h -rc 0xE0000000 -o sregtest.bin sregtest.o

sregtest.o:	sregtest.s
		$(BUILD)/bin/as -o sregtest.o sregtest.s

run:		sregtest.bin
		$(BUILD)/bin/sim -i -s 1 -t 0 -r sregtest.bin

clean:
		rm -f *~ sregtest.o sregtest.bin sregtest.exo
