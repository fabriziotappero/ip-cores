#
# Makefile for kbdtest ROM
#

BUILD = ../../build

KBDTEST_SRC = start.s main.c lib.c serial.s end.s

.PHONY:		all install run clean

all:		kbdtest.exo

install:	kbdtest.exo

kbdtest.exo:	kbdtest.bin
		$(BUILD)/bin/bin2exo -S2 0 kbdtest.bin kbdtest.exo

kbdtest.bin:	$(KBDTEST_SRC)
		$(BUILD)/bin/lcc -A -Wo-rom -Wl-rd -Wl0xC03F0000 \
		  -Wl-m -Wlkbdtest.map -o kbdtest.bin $(KBDTEST_SRC)

run:		kbdtest.bin
		$(BUILD)/bin/sim -i -c -s 1 -t 0 -r kbdtest.bin

clean:
		rm -f *~
		rm -f kbdtest.map kbdtest.bin kbdtest.exo
