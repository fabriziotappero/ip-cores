CC=	gcc
CFLAGS=	-Wall -g -std=c99  -mcmodel=large #-O2
LDFLAGS=-lreadline
PROG=	emulator
OBJS=	main.o regs.o instructions.o object.o memory.o microcode.o machine.o breakpoint.o debug.o hash.o linkedlist.o alloc.o print.o io.o bits.o profiler.o
MEMPROG=memtool
MEMOBJS=memtool.o memory.o object.o regs.o debug.o hash.o linkedlist.o alloc.o io.o bits.o
BINPROG=bindump
BINOBJS=bindump.o

.PHONY: all clean run

all: $(PROG) $(MEMPROG) $(BINPROG)

$(MEMPROG): $(MEMOBJS)
	$(CC) -o $(MEMPROG) $(MEMOBJS) $(LDFLAGS)

$(PROG): $(OBJS)
	$(CC) -o $(PROG) $(OBJS) $(LDFLAGS)

$(BINPROG): $(BINOBJS)
	$(CC) -o $(BINPROG) $(BINOBJS)

memory.bin: memtool /tmp/initmem
	./memtool /tmp/initmem memory.bin

# initmem: /tmp/initmem initmem_builtins
# 	cat /tmp/initmem initmem_builtins >initmem

# initmem_builtins: initmem_builtins.py
# 	./initmem_builtins.py >initmem_builtins

regfile.bin: memtool /tmp/regfile
	./memtool /tmp/regfile regfile.bin

microprogram.foo: /tmp/microcode bindump
	./bindump /tmp/microcode microprogram.foo 48 4000
regfile.foo: regfile.bin bindump
	./bindump regfile.bin regfile.foo 32

run: $(PROG) memory.bin regfile.bin
	./emulator -f b:memory.bin -f k:keyboard -f s:screen -f o:serial_out -f f:filesystem -r regfile.bin -M 

sim: $(PROG) memory.bin regfile.bin
	./emulator -z igorfibtest -f b:memory.bin -f k:igorfib.lisp -f s:sf -f o:so -f f:filesystem -r regfile.bin -M -a 128 -h 4096 -t 2bit


clean:
	rm -f $(PROG) $(OBJS) $(MEMOBJS) $(BINOBJS) memory.bin regfile.bin
