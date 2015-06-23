#
# Makefile for "mkpart", a program to write the partition table
# and the bootblock on a hard disk
#

BUILD = ../../build

SRC = start.s main.c iolib.c biolib.c end.s
BIN = mkpart.bin
MAP = mkpart.map
EXO = mkpart.exo

.PHONY:		all install run clean

all:		$(BIN) $(EXO)

install:	$(BIN) $(EXO)
		mkdir -p $(BUILD)/stdalone
		cp $(BIN) $(BUILD)/stdalone
		cp $(MAP) $(BUILD)/stdalone
		cp $(EXO) $(BUILD)/stdalone

run:		$(BIN)
		$(BUILD)/bin/sim -i -s 1 -t 0 -l $(BIN) -a 0x10000 \
		  -d $(BUILD)/run/disk.img

$(EXO):		$(BIN)
		$(BUILD)/bin/bin2exo -S2 0x10000 $(BIN) $(EXO)

$(BIN):		$(SRC) mboot.dump
		$(BUILD)/bin/lcc -A -Wo-kernel \
		  -Wl-m -Wl$(MAP) -o $(BIN) $(SRC)

mboot.dump:	dump/dump mboot
		./dump/dump mboot mboot.dump

dump/dump:
		$(MAKE) -C dump all

mboot:		mkmboot/mbootblk mkptbl/parttbl
		dd if=/dev/zero of=mboot bs=512 count=32
		dd if=mkmboot/mbootblk of=mboot bs=512 conv=notrunc
		dd if=mkptbl/parttbl of=mboot bs=512 seek=1 conv=notrunc

mkptbl/parttbl:
		$(MAKE) -C mkptbl all

mkmboot/mbootblk:
		$(MAKE) -C mkmboot all

clean:
		$(MAKE) -C dump clean
		$(MAKE) -C mkptbl clean
		$(MAKE) -C mkmboot clean
		rm -f *~ mboot mboot.dump $(BIN) $(MAP) $(EXO)
