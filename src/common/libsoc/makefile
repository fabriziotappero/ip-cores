
#-- Set up toolchain -- modify as needed ---------------------------------------

BIN_MIPS = C:/dev/embedded/SourceryGpp/mips-elf-11-03.52/bin
CC = $(BIN_MIPS)/mips-sde-elf-gcc.exe $(CFLAGS)
AS = $(BIN_MIPS)/mips-sde-elf-as
AR = $(BIN_MIPS)/mips-sde-elf-ar
LD = $(BIN_MIPS)/mips-sde-elf-ld
DUMP = $(BIN_MIPS)/mips-sde-elf-objdump
COPY = $(BIN_MIPS)/mips-sde-elf-objcopy


#-- Common variables -----------------------------------------------------------

CFLAGS  = -O2 -Wall -c -s -fno-builtin -nostdlib -nodefaultlibs \
          -msoft-float -mips1 -G0

#-- IMPORTANT: List of object files to be included in the library
OBJS    = hw_ion_mpu.o soc.o syscalls.o printf-stdarg.o \
          fp-bit-float.o fp-bit-double.o

SRC = ./src

#-- Targets & rules ------------------------------------------------------------

libsoc.a: $(OBJS)
	$(AR) rvs libsoc.a $(OBJS)
#	-@$(DUMP) -m mips --disassemble soc.o > soc.lst

soc.o:              $(SRC)/soc.h
printf-stdarg.o:
syscalls.o:         $(SRC)/soc.h
hw_ion_mpu.o:       $(SRC)/soc.h $(SRC)/hw.h
# The FP math library is compiled separately for float support...
fp-bit-float.o: $(SRC)/fp-bit.c
	$(CC) $(CFLAGS) -DFLOAT=1 $(SRC)/fp-bit.c -o fp-bit-float.o
# ...and for double support
fp-bit-double.o:
	$(CC) $(CFLAGS) $(SRC)/fp-bit.c -o fp-bit-double.o

#-- Let's make some implicit rules explicit for clarity (well, 'clarity')

%.o: $(SRC)/%.c
	$(CC) $(CFLAGS) $< -o $@

#-- And now the usual housekeeping stuff ---------------------------------------

.PHONY: clean

clean:
	-$(RM) *.o *.obj *.map *.lst *.hex *.exe *.axf *.code *.data *.bin

