#
# Makefile for "dhrystone", the well-known integer benchmark
#

BUILD = ../../build

SRC = port/start.s dhry_1.c dhry_2.c port/dhry_utils.c \
      port/iolib.c port/biolib.c port/end.s
BIN = dhrystone.bin
MAP = dhrystone.map
EXO = dhrystone.exo

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
		$(BUILD)/bin/lcc -A -Wo-kernel -Wl-m -Wl$(MAP) \
		  -o $(BIN) -DNOFLOAT -DSTANDALONE -DRUNS=100000 \
		  -I. -Iport $(SRC)

clean:
		rm -f port/*~ *~ $(BIN) $(MAP) $(EXO)
