# Makefile by Takar

SRCS=testbench.c
ELFFILE=rom
CC=mb-gcc

XILFLAGS=-mxl-soft-div -msoft-float -mxl-barrel-shift -mno-xl-soft-mul
CXXFLAGS=-g -ansi -pedantic -Wall
LNKFLAGS=-Wl,-defsym -Wl,_STACK_SIZE=0x4000 -Wl,-defsym -Wl,_HEAP_SIZE=0x4000
LIBFLAGS=
INCFLAGS=

cc:
	$(CC) $(XILFLAGS) $(CXXFLAGS) $(LNKFLAGS) $(LIBFLAGS) $(INCFLAGS) $(CCFLAGS) $(SRCS) -o $(ELFFILE).elf

listing: cc
	mb-objdump -DSCz $(ELFFILE).elf > $(ELFFILE).dump

bin: cc
	mb-objcopy -O binary $(ELFFILE).elf $(ELFFILE).bin

mem: bin
	../util/bin2mem < $(ELFFILE).bin > $(ELFFILE).mem
	../util/bin2mem4 < $(ELFFILE).bin

vhd: bin
	../util/bin2rom $(ELFFILE).bin $(ELFFILE).vhd 12

all: cc listing bin mem

clean:
	rm -f *~ *.bak $(ELFFILE).elf *.mem $(ELFFILE).dump $(ELFFILE).srec $(ELFFILE).vmem $(ELFFILE).mem $(ELFFILE).vhd $(ELFFILE).bin
