#
# Makefile for tlbtest ROM
#

BUILD = ../../build

TLBTEST_SRC = start.s main.c lib.c serial.s end.s

.PHONY:		all install run clean

all:		tlbtest.exo

install:	tlbtest.exo

tlbtest.exo:	tlbtest.bin
		$(BUILD)/bin/bin2exo -S2 0 tlbtest.bin tlbtest.exo

tlbtest.bin:	$(TLBTEST_SRC)
		$(BUILD)/bin/lcc -A -Wo-rom -Wl-rd -Wl0xC03F0000 \
		  -Wl-m -Wltlbtest.map -o tlbtest.bin $(TLBTEST_SRC)

run:		tlbtest.bin
		$(BUILD)/bin/sim -i -s 1 -t 0 -r tlbtest.bin

clean:
		rm -f *~
		rm -f tlbtest.map tlbtest.bin tlbtest.exo
