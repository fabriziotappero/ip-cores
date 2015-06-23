#
# Makefile for ECO32 ROM monitor
#

BUILD = ../../../../build

SRC = start.s \
      ../../common/main.c \
      ../../common/command.c \
      ../../common/instr.c \
      ../../common/asm.c \
      ../../common/disasm.c \
      ../../common/load.c \
      ../../common/boot.c \
      ../../common/cpu.c \
      ../../common/mmu.c \
      ../../common/getline.c \
      ../../common/romlib.c \
      ../../common/keyboard.s \
      ../../kbdtbls/kbdtbls.s \
      ../../common/display.s \
      ../../common/serial.s \
      ../../common/dskctl.s \
      ../../common/dskser.s \
      ../../common/end.s

.PHONY:		all install clean

all:		monitor.bin

install:	monitor.bin
		mkdir -p $(BUILD)/monitor/simulator
		cp monitor.bin $(BUILD)/monitor/simulator

monitor.bin:	$(SRC)
		$(BUILD)/bin/lcc -A -Wo-rom -Wl-rc -Wl0xC0000000 \
		  -Wl-rd -Wl0xC000C000 \
		  -Wl-m -Wlmonitor.map \
		  -o prelim.bin $(SRC)
		cat ../../copy/copy.bin prelim.bin >monitor.bin
		rm prelim.bin

clean:
		rm -f *~
		rm -f prelim.bin monitor.map monitor.bin
