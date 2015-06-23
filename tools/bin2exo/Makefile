#
# Makefile for binary to S-record converter
#

BUILD = ../../build

.PHONY:		all install clean

all:		bin2exo

install:	bin2exo
		mkdir -p $(BUILD)/bin
		cp bin2exo $(BUILD)/bin

bin2exo:	bin2exo.c
		gcc -g -Wall -o bin2exo bin2exo.c

clean:
		rm -f *~ bin2exo
