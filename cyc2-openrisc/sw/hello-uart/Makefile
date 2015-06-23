ifndef CROSS_COMPILE
CROSS_COMPILE = or32-uclinux-
CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)ld
NM = $(CROSS_COMPILE)nm
endif

export	CROSS_COMPILE

all: hello.intel.hex

reset.o: reset.S Makefile
	$(CC) -g -c -o $@ $< $(CFLAGS)

hello.o: hello.c Makefile board.h
	$(CC) -g -c -o $@ $< $(CFLAGS)

hello.or32: reset.o hello.o Makefile
	$(LD) -Tram.ld -o $@ reset.o hello.o $(LIBS)
	$(CROSS_COMPILE)objdump -D $@ > hello.dis

hello.bin: hello.or32
	$(CROSS_COMPILE)objcopy hello.or32 hello.bin -O binary -I elf32-or32

hello.hex: hello.bin
	perl bin2hex.pl -i hello.bin -o hello.hex

hello.intel.hex: hello.hex
	perl hex2bram.pl -i hello.hex -s 2000 

System.map: hello.or32
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
