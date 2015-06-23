#
# Makefile for serial line load server
#

BUILD = ../../build

.PHONY:		all install clean

all:		loadserv

install:	loadserv
		mkdir -p $(BUILD)/bin
		cp loadserv $(BUILD)/bin

loadserv:	loadserv.c
		gcc -g -Wall -o loadserv loadserv.c

clean:
		rm -f *~ loadserv
