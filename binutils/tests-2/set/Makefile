BUILD = ../../../build

all:
	$(BUILD)/bin/as -o set.o set.s
	$(BUILD)/bin/ld -o set set.o
	hexdump set

clean:
	rm -f *~ set set.o
