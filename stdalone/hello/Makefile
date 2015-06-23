#
# Makefile for "hello", a program for testing the boot loader
#

BUILD = ../../build

SRC = hello.s
OBJ = hello.o
BIN = hello.bin
MAP = hello.map
EXO = hello.exo

.PHONY:		all install run clean

all:		$(BIN) $(EXO)

install:	$(BIN) $(EXO)
		mkdir -p $(BUILD)/stdalone
		cp $(BIN) $(BUILD)/stdalone
		cp $(MAP) $(BUILD)/stdalone
		cp $(EXO) $(BUILD)/stdalone

run:		$(BIN)
		$(BUILD)/bin/sim -i -s 1 -t 0 -l $(BIN) -a 0x10000

$(EXO):		$(BIN)
		$(BUILD)/bin/bin2exo -S2 0x10000 $(BIN) $(EXO)

$(BIN):		$(OBJ)
		$(BUILD)/bin/ld -h -rc 0xC0010000 \
		  -m $(MAP) -o $(BIN) $(OBJ)

$(OBJ):		$(SRC)
		$(BUILD)/bin/as -o $(OBJ) $(SRC)

clean:
		rm -f *~ $(OBJ) $(BIN) $(MAP) $(EXO)
