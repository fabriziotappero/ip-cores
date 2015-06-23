#
# Makefile for xcptest ROM
#

BUILD = ../../build

XCPTEST_SRC = start.s main.c lib.c serial.s end.s

.PHONY:		all install run clean

all:		xcptest.exo

install:	xcptest.exo

xcptest.exo:	xcptest.bin
		$(BUILD)/bin/bin2exo -S2 0 xcptest.bin xcptest.exo

xcptest.bin:	$(XCPTEST_SRC)
		$(BUILD)/bin/lcc -A -Wo-rom -Wl-rd -Wl0xC03F0000 \
		  -Wl-m -Wlxcptest.map -o xcptest.bin $(XCPTEST_SRC)

run:		xcptest.bin
		$(BUILD)/bin/sim -i -s 1 -t 0 -r xcptest.bin

clean:
		rm -f *~
		rm -f xcptest.map xcptest.bin xcptest.exo
