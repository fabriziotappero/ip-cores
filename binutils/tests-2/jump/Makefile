BUILD = ../../../build

all:
	$(BUILD)/bin/as -o jump1.o jump1.s
	$(BUILD)/bin/as -o jump2.o jump2.s
	$(BUILD)/bin/ld -rc 0x12345678 -o jump jump1.o jump2.o
	hexdump jump

clean:
	rm -f *~ jump1.o jump2.o jump
