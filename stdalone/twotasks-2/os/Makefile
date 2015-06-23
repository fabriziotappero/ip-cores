BUILD = ../../../build

SRC = start.s main.c end.s
BIN = twotasks-2.bin
MAP = twotasks-2.map
EXO = twotasks-2.exo

all:		$(BIN) $(EXO)

run:		$(BIN)
		$(BUILD)/bin/sim -i -s 1 -t 0 -l $(BIN) -a 0x10000

$(EXO):		$(BIN)
		$(BUILD)/bin/bin2exo -S2 0x10000 $(BIN) $(EXO)

$(BIN):		$(SRC) task1.dump task2.dump
		$(BUILD)/bin/lcc -A -Wo-kernel \
		  -Wl-m -Wl$(MAP) -o $(BIN) $(SRC)

task1.dump:
		../dump/dump ../task1/task1 task1.dump

task2.dump:
		../dump/dump ../task2/task2 task2.dump

clean:
		rm -f *~ task1.dump task2.dump $(BIN) $(MAP) $(EXO)
