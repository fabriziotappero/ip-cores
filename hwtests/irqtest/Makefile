#
# Makefile for irqtest ROM
#

BUILD = ../../build

.PHONY:		all install run clean

all:		irqtest.exo

install:	irqtest.exo

irqtest.exo:	irqtest.bin
		$(BUILD)/bin/bin2exo -S2 0 irqtest.bin irqtest.exo

irqtest.bin:	irqtest.o
		$(BUILD)/bin/ld -h -rc 0xE0000000 \
		  -o irqtest.bin irqtest.o

irqtest.o:	irqtest.s
		$(BUILD)/bin/as -o irqtest.o irqtest.s

run:		irqtest.bin
		$(BUILD)/bin/sim -i -s 1 -t 0 -r irqtest.bin

clean:
		rm -f *~ irqtest.o irqtest.bin irqtest.exo
