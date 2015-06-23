#
# Makefile for bitfile to Intel hex converter
#

BUILD = ../../build

.PHONY:		all install clean

all:		bit2mcs

install:	bit2mcs
		mkdir -p $(BUILD)/bin
		cp bit2mcs $(BUILD)/bin

bit2mcs:	bit2mcs.c
		gcc -g -Wall -o bit2mcs bit2mcs.c

clean:
		rm -f *~ bit2mcs
