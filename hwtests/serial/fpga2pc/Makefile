#
# Makefile for serial line test program (FPGA --> PC)
#

BUILD = ../../../build

.PHONY:		all install clean

all:		send0.exo send1.exo receive

install:	send0.exo send1.exo receive

send0.o:	send0.s
		$(BUILD)/bin/as -o send0.o send0.s

send1.o:	send1.s
		$(BUILD)/bin/as -o send1.o send1.s

send0.bin:	send0.o
		$(BUILD)/bin/ld -h -rc 0xE0000000 -o send0.bin send0.o

send1.bin:	send1.o
		$(BUILD)/bin/ld -h -rc 0xE0000000 -o send1.bin send1.o

send0.exo:	send0.bin
		$(BUILD)/bin/bin2exo -S2 0 send0.bin send0.exo

send1.exo:	send1.bin
		$(BUILD)/bin/bin2exo -S2 0 send1.bin send1.exo

receive:	receive.c
		gcc -g -Wall -o receive receive.c

clean:
		rm -f *~
		rm -f send0.o send0.bin send0.exo
		rm -f send1.o send1.bin send1.exo
		rm -f receive
