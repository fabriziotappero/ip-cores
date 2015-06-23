# Makefile for XUM
# 
# Compiles code to run on the XUM platform, which
# is based on MIPS32 and a GCC cross-compiler toolchain.
#
# Author: Grant Ayers (ayers@cs.utah.edu)
# Date:   3 July 2012
#

SHELL = /bin/sh

SRC          = ../src
MIPS_PREFIX  = /home/User/XUM/gnu_mips/crosstools
MIPS_BIN     = $(MIPS_PREFIX)/bin
MIPS_LIB     = $(MIPS_PREFIX)/mips-elf/lib
MIPS_CC      = $(MIPS_BIN)/mips-elf-gcc-4.7.1.exe
MIPS_AS      = $(MIPS_BIN)/mips-elf-as.exe
MIPS_LD      = $(MIPS_BIN)/mips-elf-ld.exe
MIPS_OBJDUMP = $(MIPS_BIN)/mips-elf-objdump.exe
MIPS_OBJCOPY = $(MIPS_BIN)/mips-elf-objcopy.exe
UTIL_PREFIX  = /home/User/XUM/demos/util
UTIL_CONVBIN = $(UTIL_PREFIX)/bintohex.exe
UTIL_CONVXUM = $(UTIL_PREFIX)/bintoxum.exe

AS_FLAGS      = -march=mips32 -EB -G0
LD_FLAGS      = -EB -static -Map app.map -T ../src/os/xum.ls
LD_LIBS       = -lm -lc -lgcc
LD_SEARCH     = -L$(MIPS_PREFIX)/mips-elf/lib \
                -L$(MIPS_PREFIX)/lib/gcc/mips-elf/4.7.1
LD_DRIVER     = $(MIPS_LD) $(LD_FLAGS) $(LD_SEARCH) $(LD_LIBS)
CC_FLAGS_ARCH = -march=mips32 -EB -msoft-float -mno-mips16 -mno-branch-likely \
                -mgpopt
CC_FLAGS_LANG = -Wall -O2
CC_FLAGS_INC  = -I../src/
CC_FLAGS_AS   = -Wa,-EB,-mips32,-msoft-float
CC_FLAGS_LD   = -nostdlib -nostartfiles -static -T ../src/os/xum.ls
CC_FLAGS_LIB  = -lm -lc -lgcc
CC_DRIVER     = $(MIPS_CC) $(CC_FLAGS_ARCH) $(CC_FLAGS_LANG) \
                $(CC_FLAGS_AS) $(CC_FLAGS_INC)


all : app

app : app.o uart.o lcd.o boot.o vectors.o exceptions.o exception_handler.o piezo.o
	$(LD_DRIVER) $^ -o app.exe
	@$(MIPS_OBJDUMP) -EB --disassemble app.exe > app.lst
	@$(MIPS_OBJCOPY) -O binary -j .text  app.exe app-code.bin
	@$(MIPS_OBJCOPY) -O binary -j .data  app.exe app-data1.bin
	@$(MIPS_OBJCOPY) -O binary -j .sdata app.exe app-data2.bin
	@$(MIPS_OBJCOPY) -O binary -j .sbss  app.exe app-data3.bin
	@$(MIPS_OBJCOPY) -O binary -j .bss   app.exe app-data4.bin
	@cat app-data1.bin app-data2.bin app-data3.bin app-data4.bin >> app-data.bin
	@$(UTIL_CONVXUM) -d 4096 app-code.bin app-data.bin app.xum
	#@$(UTIL_CONVBIN) -c -b app-code.bin app-code.coe
	$(UTIL_CONVBIN) -c -b app.xum app.coe



app.o : $(SRC)/app/app.c
	$(CC_DRIVER) -c $(SRC)/app/app.c -o app.o

uart.o : $(SRC)/drivers/uart.c $(SRC)/drivers/uart.h
	$(CC_DRIVER) -c $(SRC)/drivers/uart.c -o uart.o

i2c.o : $(SRC)/drivers/i2c.c $(SRC)/drivers/i2c.h
	$(CC_DRIVER) -c $(SRC)/drivers/i2c.c -o i2c.o

lcd.o : $(SRC)/drivers/lcd.c $(SRC)/drivers/lcd.h
	$(CC_DRIVER) -c $(SRC)/drivers/lcd.c -o lcd.o

monitor.o : $(SRC)/drivers/monitor.c $(SRC)/drivers/monitor.h i2c.o
	$(CC_DRIVER) -c $(SRC)/drivers/monitor.c -o monitor.o

piezo.o : $(SRC)/drivers/piezo.c $(SRC)/drivers/piezo.h
	$(CC_DRIVER) -c $(SRC)/drivers/piezo.c -o piezo.o

exception_handler.o : $(SRC)/os/exception_handler.c $(SRC)/os/exception_handler.h lcd.o piezo.o monitor.o
	$(CC_DRIVER) -c $(SRC)/os/exception_handler.c -o exception_handler.o

boot.o : $(SRC)/os/boot.asm
	$(MIPS_AS) $(AS_FLAGS) -o boot.o $(SRC)/os/boot.asm

vectors.o : $(SRC)/os/vectors.asm
	$(MIPS_AS) $(AS_FLAGS) -o vectors.o $(SRC)/os/vectors.asm

exceptions.o : $(SRC)/os/exceptions.asm
	$(MIPS_AS) $(AS_FLAGS) -o exceptions.o $(SRC)/os/exceptions.asm

clean :
	rm -f *.o *.exe *.map *.coe *.bin *.map *.xum *.lst

