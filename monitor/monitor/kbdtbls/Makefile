#
# Makefile to construct the keyboard mapping tables
#

.PHONY:		all install clean

all:		kbdtbls.s

install:	kbdtbls.s

kbdtbls.s:	mkkbdtbls
		./mkkbdtbls >kbdtbls.s

mkkbdtbls:	mkkbdtbls.c
		gcc -g -Wall -o mkkbdtbls mkkbdtbls.c

clean:
		rm -f *~ mkkbdtbls kbdtbls.s
