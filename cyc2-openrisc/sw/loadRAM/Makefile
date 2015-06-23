ifndef CROSS_COMPILE
CROSS_COMPILE = or32-uclinux-
CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)ld
NM = $(CROSS_COMPILE)nm
endif

export	CROSS_COMPILE

all: loadRAM.intel.hex

reset.o: reset.S Makefile board.h
	$(CC) -g -c -o $@ $< $(CFLAGS)

jumpToRAM.o: jumpToRAM.S Makefile
	$(CC) -g -c -o $@ $< $(CFLAGS)

loadRAM.o: loadRAM.c Makefile board.h
	$(CC) -g -c -o $@ $< $(CFLAGS)

loadRAM.or32: reset.o jumpToRAM.o loadRAM.o Makefile
	$(LD) -Tram.ld -o $@ reset.o loadRAM.o jumpToRAM.o $(LIBS)
	$(CROSS_COMPILE)objdump -D $@ > loadRAM.dis

loadRAM.bin: loadRAM.or32
	or32-uclinux-objcopy loadRAM.or32 loadRAM.bin -O binary -I elf32-or32

loadRAM.hex: loadRAM.bin
	perl bin2hex.pl -i loadRAM.bin -o loadRAM.hex

loadRAM.intel.hex: loadRAM.hex
	perl hex2bram.pl -i loadRAM.hex -s 2000

System.map: loadRAM.or32
	@$(NM) $< | \
		grep -v '\(compiled\)\|\(\.o$$\)\|\( [aUw] \)\|\(\.\.ng$$\)\|\(LASH[RL]DI\)' | \
		sort > System.map

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
