BUILD = ../../../build

all:		task

task:		c0.o task.o putchar.o c1.o
		$(BUILD)/bin/ld -o task c0.o task.o putchar.o c1.o

c0.o:		c0.s
		$(BUILD)/bin/as -o c0.o c0.s

task.o:		task.c
		$(BUILD)/bin/lcc -A -c -o task.o task.c

putchar.o:	putchar.s
		$(BUILD)/bin/as -o putchar.o putchar.s

c1.o:		c1.s
		$(BUILD)/bin/as -o c1.o c1.s

clean:
		rm -f *~ c0.o task.o putchar.o c1.o task
