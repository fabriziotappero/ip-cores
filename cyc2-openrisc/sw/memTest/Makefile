ifndef CROSS_COMPILE
CROSS_COMPILE = or32-uclinux-
CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)ld
NM = $(CROSS_COMPILE)nm
endif

export	CROSS_COMPILE

all: memTest.intel.hex memTestDramResident.bin memTestSim.intel.hex

reset.o: reset.S Makefile
	$(CC) -g -c -o $@ $< $(CFLAGS)

memTest.o: memTest.c Makefile board.h
	$(CC) -g -c -o $@ $< $(CFLAGS)





memTest.or32: reset.o memTest.o Makefile
	$(LD) -Tram.ld -o $@ reset.o memTest.o $(LIBS)
	$(CROSS_COMPILE)objdump -D $@ > memTest.dis

memTest.bin: memTest.or32
	or32-uclinux-objcopy memTest.or32 memTest.bin -O binary -I elf32-or32

memTest.hex: memTest.bin
	perl bin2hex.pl -i memTest.bin -o memTest.hex

memTest.intel.hex: memTest.hex
	perl hex2bram.pl -i memTest.hex -s 2000

System.map: memTest.or32
	@$(NM) $< | \
		grep -v '\(compiled\)\|\(\.o$$\)\|\( [aUw] \)\|\(\.\.ng$$\)\|\(LASH[RL]DI\)' | \
		sort > System.map






memTestDramResident.or32: reset.o memTest.o Makefile
	$(LD) -Tdram.ld -o $@ reset.o memTest.o $(LIBS)
	$(CROSS_COMPILE)objdump -D $@ > memTestDramResident.dis

memTestDramResident.bin: memTestDramResident.or32
	or32-uclinux-objcopy memTestDramResident.or32 memTestDramResident.bin -O binary -I elf32-or32

SystemDramResident.map: memTestDramResident.or32
	@$(NM) $< | \
		grep -v '\(compiled\)\|\(\.o$$\)\|\( [aUw] \)\|\(\.\.ng$$\)\|\(LASH[RL]DI\)' | \
		sort > SystemDramResident.map





memTestSim.o: memTest.c Makefile board.h
	$(CC) -DSIM_COMPILE -g -c -o $@ $< $(CFLAGS)

memTestSim.or32: reset.o memTestSim.o Makefile
	$(LD) -Tram.ld -o $@ reset.o memTestSim.o $(LIBS)
	$(CROSS_COMPILE)objdump -D $@ > memTestSim.dis

memTestSim.bin: memTestSim.or32
	or32-uclinux-objcopy memTestSim.or32 memTestSim.bin -O binary -I elf32-or32

memTestSim.hex: memTestSim.bin
	perl bin2hex.pl -i memTestSim.bin -o memTestSim.hex

# Could not find a way for simulator to reference the ouput hex file
# located in this directory, so copy to sim directory
memTestSim.intel.hex: memTestSim.hex
	perl hex2bram.pl -i memTestSim.hex -s 2000
	cp memTestSim.8bit.hex ../../sim/memory.hex

#########################################################################
clean:
	find . -type f \
		\( -name 'core' -o -name '*.bak' -o -name '*~' \
		-o -name '*.o'  -o -name '*.a' -o -name '*.tmp' \
		-o -name '*.or32' -o -name '*.bin' -o -name '*.srec' \
		-o -name '*.mem' -o -name '*.img' -o -name '*.out' \
		-o -name '*.aux' -o -name '*.log' -o -name '*.hex' -o \
		-name '*.init' -o -name '*.dis' \) -print \
		| xargs rm -f
	rm -f System.map

distclean: clean
	find . -type f \
		\( -name .depend -o -name '*.srec' -o -name '*.bin' \
		-o -name '*.pdf' \) \
		-print | xargs rm -f
	rm -f $(OBJS) *.bak tags TAGS
	rm -fr *.*~
