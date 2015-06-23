BUILD = ../../../build

all:		hello.bin

hello.bin:	hello.o
		$(BUILD)/bin/ld -h -rc 0xC0000000 -o hello.bin hello.o

hello.o:	hello.s
		$(BUILD)/bin/as -o hello.o hello.s

run:		hello.bin
		$(BUILD)/bin/sim -s 1 -t 0 -l hello.bin

clean:
		rm -f *~ hello.bin hello.o
