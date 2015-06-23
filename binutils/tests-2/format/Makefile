BUILD = ../../../build

all:		format.bin

format.bin:	format.o
		$(BUILD)/bin/ld -h -rc 0xC0000000 -o format.bin \
		  -m format.map format.o

format.o:	format.s
		$(BUILD)/bin/as -o format.o format.s

run:		format.bin
		$(BUILD)/bin/sim -i -l format.bin

clean:
		rm -f *~ format.map format.bin format.o
