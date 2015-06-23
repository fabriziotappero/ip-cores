# Makefile by rockee

SRCS=testbench.c
ELFFILE=rom
CC=mb-gcc

XILFLAGS=-mxl-soft-div -msoft-float -mxl-barrel-shift -mno-xl-soft-mul
CXXFLAGS=-g -ansi -pedantic -Wall
LNKFLAGS=-L/home/daniel/Applications/Xilinx/10.1/EDK/gnu/microblaze/lin64/lib -I/home/daniel/Applications/Xilinx/10.1/EDK/gnu/microblaze/lin64/include/ -Wl,-defsym -Wl,_STACK_SIZE=0x400 -Wl,-defsym -Wl,_HEAP_SIZE=0x400
LIBFLAGS=
INCFLAGS=
SIZE=8192

cc:
	$(CC) $(XILFLAGS) $(CXXFLAGS) $(LNKFLAGS) $(LIBFLAGS) $(INCFLAGS) $(CCFLAGS) $(SRCS) -o $(ELFFILE).elf

ccx:
	mb-as test.asm -o $(ELFFILE).elf

listing: cc
	mb-objdump -DSCz $(ELFFILE).elf > $(ELFFILE).dump

bin: cc
	mb-objcopy -O binary $(ELFFILE).elf $(ELFFILE).bin

vhd: bin
	../tools/bin2rom $(ELFFILE).bin $(ELFFILE).vhd 12

srec: cc
	mb-objcopy -O srec $(ELFFILE).elf $(ELFFILE).srec

mem: srec bin listing
	../tools/bin2mem < $(ELFFILE).bin > $(ELFFILE).mem
	../tools/bin2mem4 < $(ELFFILE).bin
	../tools/srec2vram 4 $(ELFFILE).srec 0 $(SIZE) > rom.vmem
	python top.py $(SIZE)

all: cc listing bin srec mem vhd

clean:
	rm -f *~ *.bak *.pyc $(ELFFILE).elf *.mem $(ELFFILE).dump $(ELFFILE).srec $(ELFFILE).vmem $(ELFFILE).mem $(ELFFILE).vhd $(ELFFILE).bin rom.vmem  $(ELFFILE).srec
