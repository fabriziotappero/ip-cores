#
# Makefile for "dactest", a program for testing the audio DAC
#

BUILD = ../../build

SRC1 = dactest.s
OBJ1 = dactest.o
SRC2 = bell.s
OBJ2 = bell.o
BIN = dactest.bin
MAP = dactest.map
EXO = dactest.exo

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

$(BIN):		$(OBJ1) $(OBJ2)
		$(BUILD)/bin/ld -h -rc 0xC0010000 \
		  -m $(MAP) -o $(BIN) $(OBJ1) $(OBJ2)

$(OBJ1):	$(SRC1)
		$(BUILD)/bin/as -o $(OBJ1) $(SRC1)

$(OBJ2):	$(SRC2)
		$(BUILD)/bin/as -o $(OBJ2) $(SRC2)

$(SRC2):	genbell
		./genbell >$(SRC2)

genbell:	genbell.c
		gcc -g -Wall -o genbell genbell.c -lm

clean:
		rm -f genbell $(SRC2) $(OBJ2)
		rm -f $(OBJ1) $(BIN) $(MAP) $(EXO)
		rm -f *~
