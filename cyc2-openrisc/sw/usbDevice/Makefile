ifndef CROSS_COMPILE
CROSS_COMPILE = or32-uclinux-
CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)ld
NM = $(CROSS_COMPILE)nm
endif

export	CROSS_COMPILE

all: usbDevice.bin

reset.o: reset.S Makefile
	$(CC) -g -c -o $@ $< $(CFLAGS)

usbDevice.o: usbDevice.c Makefile board.h usbHostSlave.h
	$(CC) -g -c -o $@ $< $(CFLAGS)


# Generate DRAM resident image files
usbDevice.or32: reset.o usbDevice.o Makefile
	$(LD) -Tram.ld -o $@ reset.o usbDevice.o $(LIBS)
	$(CROSS_COMPILE)objdump -D $@ > usbDevice.dis

usbDevice.bin: usbDevice.or32
	or32-uclinux-objcopy usbDevice.or32 usbDevice.bin -O binary -I elf32-or32

System.map: usbDevice.or32
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
