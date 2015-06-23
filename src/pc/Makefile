#
# Makefile to build the analyzer programs running on the PC side
#

all:		receive display

receive:	receive.c
		gcc -Wall -o receive receive.c

display:	display.c
		gcc -Wall -o display display.c

clean:
		rm -f *~ receive display
