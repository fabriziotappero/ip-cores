GCC_MIPS = mips-linux-gnu-gcc $(CFLAGS)
AS_MIPS = mips-linux-gnu-as
LD_MIPS = mips-linux-gnu-ld
INCLUDE = -Iinclude/
RM = rm -rf
CP = cp

CFLAGS = -O0 -EB -Wall -c -s -fno-pic -mips1 -mno-check-zero-division -mdivide-traps -mno-abicalls $(INCLUDE)

hello:
	@echo "................ Compiling Hello Source Code ......................"
	$(AS_MIPS) -EB -o start.o start.asm
	$(GCC_MIPS) -EB helloWorld.c uart.c stdio.c
	$(LD_MIPS) -EB -T edge.linkcmd start.o helloWorld.o uart.o stdio.o -o helloWorld.elf

leds:
	@echo "................ Compiling leds Source Code ......................"
	$(AS_MIPS) -EB -o start.o start.asm
	$(GCC_MIPS) -EB ledsOutWithDelay.c Edge_Atlys_LEDS.c
	$(LD_MIPS) -EB -T edge.linkcmd start.o Edge_Atlys_LEDS.o ledsOutWithDelay.o -o ledsDelay.elf 

hello_atlys: hello
	 @echo "................ Programming bit file ......................"
	data2mem -bt ../../HW/Boards/Atlys/edge_atlys.bit -bd helloWorld.elf -bm ../../HW/Boards/Atlys/EdgeMemMap.bmm -o b edge_processor.bit

leds_atlys: leds
	@echo "................ Programming bit file ......................"
	data2mem -bt ../../HW/Boards/Atlys/edge_atlys.bit -bd ledsDelay.elf -bm ../../HW/Boards/Atlys/EdgeMemMap.bmm -o b edge_processor.bit

clean:
	-$(RM) *.o *.elf *.bit *~ *.log *.cmd
