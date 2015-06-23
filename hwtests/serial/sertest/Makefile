#
# Makefile for serial line test program (FPGA <--> PC)
#

BUILD = ../../../build

.PHONY:		all install clean

all:		echo0.exo echo1.exo sertest

install:	echo0.exo echo1.exo sertest

echo0.o:	echo0.s
		$(BUILD)/bin/as -o echo0.o echo0.s

echo1.o:	echo1.s
		$(BUILD)/bin/as -o echo1.o echo1.s

echo0.bin:	echo0.o
		$(BUILD)/bin/ld -h -rc 0xE0000000 -o echo0.bin echo0.o

echo1.bin:	echo1.o
		$(BUILD)/bin/ld -h -rc 0xE0000000 -o echo1.bin echo1.o

echo0.exo:	echo0.bin
		$(BUILD)/bin/bin2exo -S2 0 echo0.bin echo0.exo

echo1.exo:	echo1.bin
		$(BUILD)/bin/bin2exo -S2 0 echo1.bin echo1.exo

sertest:	sertest.c
		gcc -g -Wall -o sertest sertest.c

clean:
		rm -f *~
		rm -f echo0.o echo0.bin echo0.exo
		rm -f echo1.o echo1.bin echo1.exo
		rm -f sertest
