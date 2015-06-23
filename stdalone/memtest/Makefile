#
# Makefile for "memtest", a program for testing the memory
#

BUILD = ../../build

SRC = start.s main.c iolib.c biolib.c end.s
BIN = memtest.bin
MAP = memtest.map
EXO = memtest.exo

.PHONY:		all install run clean

all:		$(BIN) $(EXO)

install:	$(BIN) $(EXO)
		mkdir -p $(BUILD)/stdalone
		cp $(BIN) $(BUILD)/stdalone
		cp $(MAP) $(BUILD)/stdalone
		cp $(EXO) $(BUILD)/stdalone

run:		$(BIN)
		$(BUILD)/bin/sim -i -m 32 -s 1 -t 0 -l $(BIN) -a 0x10000

$(EXO):		$(BIN)
		$(BUILD)/bin/bin2exo -S2 0x10000 $(BIN) $(EXO)

$(BIN):		$(SRC)
		$(BUILD)/bin/lcc -A -Wo-kernel \
		  -Wl-m -Wl$(MAP) -o $(BIN) $(SRC)

clean:
		rm -f *~ $(BIN) $(MAP) $(EXO)
