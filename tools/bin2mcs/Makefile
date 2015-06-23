#
# Makefile for binary to Intel hex converter
#

BUILD = ../../build

.PHONY:		all install clean

all:		bin2mcs

install:	bin2mcs
		mkdir -p $(BUILD)/bin
		cp bin2mcs $(BUILD)/bin

bin2mcs:	bin2mcs.c
		gcc -g -Wall -o bin2mcs bin2mcs.c

clean:
		rm -f *~ bin2mcs
