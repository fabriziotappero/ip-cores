BUILD = ../../../build

all:		task2

task2:		c0.o task2.o putchar.o c1.o
		$(BUILD)/bin/ld -o task2 c0.o task2.o putchar.o c1.o

c0.o:		c0.s
		$(BUILD)/bin/as -o c0.o c0.s

task2.o:	task2.c
		$(BUILD)/bin/lcc -A -c -o task2.o task2.c

putchar.o:	putchar.s
		$(BUILD)/bin/as -o putchar.o putchar.s

c1.o:		c1.s
		$(BUILD)/bin/as -o c1.o c1.s

clean:
		rm -f *~ c0.o task2.o putchar.o c1.o task2
