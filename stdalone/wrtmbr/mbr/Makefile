#
# Makefile for assembling the default master boot record
#

BUILD = ../../../build

.PHONY:		all clean

all:		mbr.dump

mbr.dump:	dump mbr.bin
		./dump mbr.bin mbr.dump

dump:		dump.c
		gcc -g -Wall -o dump dump.c

mbr.bin:	mbr.o
		$(BUILD)/bin/ld -h -rc 0xC0010000 -o mbr.bin mbr.o

mbr.o:		mbr.s
		$(BUILD)/bin/as -o mbr.o mbr.s

clean:
		rm -f *~ dump mbr.o mbr.bin mbr.dump
