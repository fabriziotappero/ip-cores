#
# Makefile for "wrtmbr", a program to write a dummy MBR to the disk
#

BUILD = ../../build

SRC = start.s main.c end.s
BIN = wrtmbr.bin
MAP = wrtmbr.map
EXO = wrtmbr.exo

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

$(BIN):		$(SRC) mbr/mbr.dump
		$(BUILD)/bin/lcc -A -Wo-kernel \
		  -Wl-m -Wl$(MAP) -o $(BIN) $(SRC)

mbr/mbr.dump:
		$(MAKE) -C mbr

clean:
		$(MAKE) -C mbr clean
		rm -f *~ $(BIN) $(MAP) $(EXO)
