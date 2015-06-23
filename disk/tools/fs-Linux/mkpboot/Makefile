#
# Makefile to build the partition boot record
#

BUILD = ../../../../build

.PHONY:		all install clean

all:		pbr.bin

install:	pbr.bin
		mkdir -p $(BUILD)/run/fs-Linux
		cp pbr.bin $(BUILD)/run/fs-Linux

pbr.bin:	pbr.o
		$(BUILD)/bin/ld -h -rc 0xC0010000 -o pbr.bin pbr.o

pbr.o:		pbr.s
		$(BUILD)/bin/as -o pbr.o pbr.s

clean:
		rm -f *~ pbr.o pbr.bin
