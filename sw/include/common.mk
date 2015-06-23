# ----------------------------------------------------------------
#                                                               //
#   common.mk                                                   //
#                                                               //
#   This file is part of the Amber project                      //
#   http://www.opencores.org/project,amber                      //
#                                                               //
#   Description                                                 //
#   Contains common makefile code.                              //
#                                                               //
#   Author(s):                                                  //
#       - Conor Santifort, csantifort.amber@gmail.com           //
#                                                               //
#/ ///////////////////////////////////////////////////////////////
#                                                               //
#  Copyright (C) 2010 Authors and OPENCORES.ORG                 //
#                                                               //
#  This source file may be used and distributed without         //
#  restriction provided that this copyright statement is not    //
#  removed from the file and that any derivative work contains  //
#  the original copyright notice and the associated disclaimer. //
#                                                               //
#  This source file is free software; you can redistribute it   //
#  and/or modify it under the terms of the GNU Lesser General   //
#  Public License as published by the Free Software Foundation; //
#  either version 2.1 of the License, or (at your option) any   //
#  later version.                                               //
#                                                               //
#  This source is distributed in the hope that it will be       //
#  useful, but WITHOUT ANY WARRANTY; without even the implied   //
#  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
#  PURPOSE.  See the GNU Lesser General Public License for more //
#  details.                                                     //
#                                                               //
#  You should have received a copy of the GNU Lesser General    //
#  Public License along with this source; if not, download it   //
#  from http://www.opencores.org/lgpl.shtml                     //
#                                                               //
# ----------------------------------------------------------------

LIBC_OBJ         = ../mini-libc/printf.o ../mini-libc/libc_asm.o ../mini-libc/memcpy.o
DEP             += ../include/amber_registers.h ../mini-libc/stdio.h
TOOLSPATH        = ../tools
AMBER_CROSSTOOL ?= amber-crosstool-not-defined

  AS    = $(AMBER_CROSSTOOL)-as
  CC    = $(AMBER_CROSSTOOL)-gcc
 CXX    = $(AMBER_CROSSTOOL)-g++
  AR    = $(AMBER_CROSSTOOL)-ar
  LD    = $(AMBER_CROSSTOOL)-ld
  DS    = $(AMBER_CROSSTOOL)-objdump
  OC    = $(AMBER_CROSSTOOL)-objcopy
 ELF    = $(TOOLSPATH)/amber-elfsplitter
 BMF32  = ../tools/amber-memparams32.sh
 BMF128 = ../tools/amber-memparams128.sh

 MMP32  = $(addsuffix _memparams32.v, $(basename $(TGT)))
 MMP128 = $(addsuffix _memparams128.v, $(basename $(TGT)))
 MEM    = $(addsuffix .mem, $(basename $(TGT)))
 DIS    = $(addsuffix .dis, $(basename $(TGT)))
 FLT    = $(addsuffix .flt, $(basename $(TGT)))
 
ifdef USE_MINI_LIBC
 OBJ = $(addsuffix .o,   $(basename $(SRC))) $(LIBC_OBJ)
else
 OBJ = $(addsuffix .o,   $(basename $(SRC)))
endif

ifdef LDS
    TLDS = -T $(LDS)
else
    TLDS = 
endif

ifndef TGT
    TGT = aout.elf
endif

ifdef MIN_SIZE
    # optimize for size
    OPTIMIZE = -Os
else
    # optimize for speed
    OPTIMIZE = -O3
endif

 MAP = $(addsuffix .map, $(basename $(TGT))) 
 
 ASFLAGS = -I../include 
  CFLAGS = -c $(OPTIMIZE) -march=armv2a -mno-thumb-interwork -ffreestanding -I../include
 DSFLAGS = -C -S -EL
 LDFLAGS = -Bstatic -Map $(MAP) --strip-debug --fix-v4bx

ifdef USE_MINI_LIBC
debug:  mini-libc $(ELF) $(MMP32) $(MMP128) $(DIS)
else
debug:  $(ELF) $(MMP32) $(MMP128) $(DIS)
endif

$(MMP32): $(MEM)
	$(BMF32) $(MEM) $(MMP32)

$(MMP128): $(MEM)
	$(BMF128) $(MEM) $(MMP128)

$(MEM): $(TGT)
	$(ELF) $(TGT) > $(MEM)

$(TGT): $(OBJ)
ifdef CREATE_FLT_OUTPUT
	$(LD) $(LDFLAGS) -elf2flt=-v -elf2flt=-k -o $(FLT) $(TLDS) $(OBJ)
endif
	$(LD) $(LDFLAGS) -o $(TGT) $(TLDS) $(OBJ)
	$(OC) -R .comment -R .note $(TGT)
ifdef CHANGE_ADDRESS
	$(OC) --change-addresses -0x1000000 $(TGT)
endif

$(OBJ): $(DEP)

mini-libc:
	$(MAKE) -s -C ../mini-libc MIN_SIZE=1

$(ELF):
	$(MAKE) -s -C $(TOOLSPATH)
        
$(DIS): $(TGT)
	$(DS) $(DSFLAGS) $^ > $@

clean:
	@rm -rfv *.o *.elf *.flt *.gdb *.dis *.map *.mem *.v $(MMP32) $(MMP128)

