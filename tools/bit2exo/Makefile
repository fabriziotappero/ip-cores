#
# Makefile for bitfile to S-record converter
#

BUILD = ../../build

.PHONY:		all install clean

all:		bit2exo

install:	bit2exo
		mkdir -p $(BUILD)/bin
		cp bit2exo $(BUILD)/bin

bit2exo:	bit2exo.c
		gcc -g -Wall -o bit2exo bit2exo.c

clean:
		rm -f *~ bit2exo
