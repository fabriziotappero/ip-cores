#
# Makefile to build the master boot record
#

BUILD = ../../../../build

all:		mbr.bin

mbr.bin:	mbr.o
		$(BUILD)/bin/ld -h -rc 0xC0010000 -o mbr.bin mbr.o

mbr.o:		mbr.s
		$(BUILD)/bin/as -o mbr.o mbr.s

clean:
		rm -f *~ mbr.o mbr.bin
