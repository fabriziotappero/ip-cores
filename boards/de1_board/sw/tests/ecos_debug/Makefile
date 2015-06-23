ifndef CROSS_COMPILE 
# CROSS_COMPILE = or32-elf-
CROSS_COMPILE = or32-uclinux-
CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)ld
NM = $(CROSS_COMPILE)nm
OBJDUMP = $(CROSS_COMPILE)objdump
OBJCOPY = $(CROSS_COMPILE)objcopy
endif

export	CROSS_COMPILE

ROOT_DIR = ../../../../..
BOARD_DIR = ../../..


#
# main target
all: main.or32 System.map main_dis.txt main.hex


#
# compile the code

boot_vector_rom.o: boot_vector_rom.s or_soc.ld Makefile
	$(CC) -O2 -g -c -fomit-frame-pointer -o $@ $< $(CFLAGS)

reset.o: reset.s or_soc.ld Makefile
	$(CC) -O2 -g -c -fomit-frame-pointer -o $@ $< $(CFLAGS)

serial.o: serial.c serial.h Makefile
	$(CC) -O2 -g -c -fomit-frame-pointer -o $@ $< $(CFLAGS)

main.o: main.c Makefile
	$(CC) -O2 -g -c -fomit-frame-pointer -o $@ $< $(CFLAGS)

#
# link the objects

main.or32: boot_vector_rom.o reset.o serial.o main.o Makefile
	$(LD) --warn-common -Tor_soc.ld -o $@ boot_vector_rom.o reset.o main.o serial.o $(LIBS)

#
# dump human readable stuff

System.map: main.or32
	@$(NM) $< | \
		grep -v '\(compiled\)\|\(\.o$$\)\|\( [aUw] \)\|\(\.\.ng$$\)\|\(LASH[RL]DI\)' | \
		sort > System.map

main_dis.txt: main.or32
	$(OBJDUMP) -h -t -D main.or32 >main_dis.txt

#
# generate programing files

# main.hex: Makefile main.or32 $(ROOT_DIR)/sw/u-boot-1.3.4/u-boot.bin
main.hex: Makefile main.or32 
	$(OBJCOPY) -O binary  -j .boot_vector_rom main.or32 boot_vector_rom.bin
	$(ROOT_DIR)/sw/perl/bin2readmemh.pl -s 32 -f boot_vector_rom.bin > boot_vector_rom.txt
	$(OBJCOPY) -O binary  -R .boot_vector_rom main.or32 boot_rom_0.bin
	$(ROOT_DIR)/sw/perl/bin2readmemh.pl -s 32 -f boot_rom_0.bin > boot_rom_0.txt
	$(OBJCOPY) -O binary $(ROOT_DIR)/sw/ecos_debug/install/bin/redboot.elf redboot.bin
	$(ROOT_DIR)/sw/perl/bin2readmemh.pl -s 8 -f ./redboot.bin > boot_rom_2.txt
	cp *.txt $(BOARD_DIR)/sw/load_this_to_ram/


#########################################################################
clean:
	find . -type f \
		\( -name 'core' -o -name '*.bak' -o -name '*~' \
		-o -name '*.o'  -o -name '*.a' -o -name '*.tmp' \
		-o -name '*.or32' -o -name '*.bin' -o -name '*.srec' \
		-o -name '*.mem' -o -name '*.img' -o -name '*.out' \
		-o -name '*.aux' -o -name '*.log' \) -print \
		| xargs rm -f
	rm -f $(BOARD_DIR)/sw/load_this_to_ram/*.txt
	rm -f $(BOARD_DIR)/sw/load_this_to_ram/*.mif
	rm -f *.hex
	rm -f *.mif
	rm -f *.txt
	rm -f System.map

distclean: clean
	find . -type f \
		\( -name .depend -o -name '*.srec' -o -name '*.bin' \
		-o -name '*.pdf' -o -name '*.hex' \) \
		-print | xargs rm -f
	rm -f $(OBJS) *.bak tags TAGS
	rm -fr *.*~


