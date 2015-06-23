BUILD = ../../../build

all:		intrpt.bin

intrpt.bin:	intrpt.o
		$(BUILD)/bin/ld -h -rc 0xC0000000 -o intrpt.bin intrpt.o

intrpt.o:	intrpt.s
		$(BUILD)/bin/as -o intrpt.o intrpt.s

run:		intrpt.bin
		$(BUILD)/bin/sim -s 1 -t 0 -l intrpt.bin

clean:
		rm -f *~ intrpt.bin intrpt.o
