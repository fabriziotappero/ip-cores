BUILD = ../../../build

all:
	$(BUILD)/bin/as -o src1.o src1.s
	$(BUILD)/bin/as -o src2.o src2.s
	$(BUILD)/bin/as -o src3.o src3.s
	$(BUILD)/bin/ld -o src123 src1.o src2.o src3.o
	hexdump src123

clean:
	rm -f *~ src123 src1.o src2.o src3.o
