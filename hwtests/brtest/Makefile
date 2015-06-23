#
# Makefile for brtest ROM
#

BUILD = ../../build

.PHONY:		all install run clean

all:		brtest.exo

install:	brtest.exo

brtest.exo:	brtest.bin
		$(BUILD)/bin/bin2exo -S2 0 brtest.bin brtest.exo

brtest.bin:	brtest.o
		$(BUILD)/bin/ld -h -rc 0xE0000000 -o brtest.bin brtest.o

brtest.o:	brtest.s
		$(BUILD)/bin/as -o brtest.o brtest.s

brtest.s:	mkbrtest
		./mkbrtest > brtest.s

mkbrtest:	mkbrtest.c
		gcc -g -Wall -o mkbrtest mkbrtest.c

run:		brtest.bin
		$(BUILD)/bin/sim -i -s 1 -t 0 -r brtest.bin

clean:
		rm -f *~ mkbrtest brtest.s brtest.o
		rm -f brtest.bin brtest.exo
