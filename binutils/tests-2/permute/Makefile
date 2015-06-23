BUILD = ../../../build

all:	all123 all132 all213 all231 all312 all321

all123:	src1.o src2.o src3.o
	$(BUILD)/bin/ld -o all123 src1.o src2.o src3.o

all132:	src1.o src2.o src3.o
	$(BUILD)/bin/ld -o all132 src1.o src3.o src2.o

all213:	src1.o src2.o src3.o
	$(BUILD)/bin/ld -o all213 src2.o src1.o src3.o

all231:	src1.o src2.o src3.o
	$(BUILD)/bin/ld -o all231 src2.o src3.o src1.o

all312:	src1.o src2.o src3.o
	$(BUILD)/bin/ld -o all312 src3.o src1.o src2.o

all321:	src1.o src2.o src3.o
	$(BUILD)/bin/ld -o all321 src3.o src2.o src1.o

src1.o:	src1.s
	$(BUILD)/bin/as -o src1.o src1.s

src2.o:	src2.s
	$(BUILD)/bin/as -o src2.o src2.s

src3.o:	src3.s
	$(BUILD)/bin/as -o src3.o src3.s

clean:
	rm -f *~ src1.o src2.o src3.o
	rm -f all123 all132 all213 all231 all312 all321
