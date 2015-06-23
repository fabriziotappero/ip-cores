# ----------------------------------------------------------------
#                                                               //
#   Amber 2 core hardware test compilation Makefile             //
#                                                               //
#   This file is part of the Amber project                      //
#   http://www.opencores.org/project,amber                      //
#                                                               //
#   Description                                                 //
#   Compiles a single hardware test and generates a .mem file   //
#   for use in Verilog simulations                              //
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

# Assembly source files
DEP      += ../../sw/include/amber_registers.h

TEST            ?= add
AMBER_CROSSTOOL ?= amber-crosstool-not-defined
TOOLSPATH        = ../../sw/tools

 TGT    = $(addsuffix .elf,            $(basename $(TEST)))
 MMP32  = $(addsuffix _memparams32.v,  $(basename $(TGT)))
 MMP128 = $(addsuffix _memparams128.v, $(basename $(TGT)))
 SRC    = $(addsuffix .S,              $(basename $(TEST)))
 MEM    = $(addsuffix .mem,            $(basename $(TGT)))
 DIS    = $(addsuffix .dis,            $(basename $(TGT)))
 OBJ    = $(addsuffix .o,              $(basename $(SRC)))
 MAP    = $(addsuffix .map,            $(basename $(TGT))) 
 LDS    = sections.lds

  AS    = $(AMBER_CROSSTOOL)-as
  CC    = $(AMBER_CROSSTOOL)-gcc
 CXX    = $(AMBER_CROSSTOOL)-g++
  AR    = $(AMBER_CROSSTOOL)-ar
  LD    = $(AMBER_CROSSTOOL)-ld
  DS    = $(AMBER_CROSSTOOL)-objdump
  OC    = $(AMBER_CROSSTOOL)-objcopy
 ELF    = ../../sw/tools/amber-elfsplitter
 BMF32  = ../../sw/tools/amber-memparams32.sh
 BMF128 = ../../sw/tools/amber-memparams128.sh
 
 ASFLAGS = -I../../sw/include
  CFLAGS = -c -march=armv2a -mno-thumb-interwork -I../../sw/include
 DSFLAGS = -C -S -EL
 LDFLAGS = -Bstatic -Map $(MAP) --fix-v4bx
 

all:  $(ELF) $(MMP32) $(MMP128) $(DIS)

$(MMP32): $(MEM)
	$(BMF32) $(MEM) $(MMP32)

$(MMP128): $(MEM)
	$(BMF128) $(MEM) $(MMP128)

$(MEM): $(TGT)
	$(ELF) $(TGT) > $(MEM)

$(TGT): $(OBJ)
	$(LD) $(LDFLAGS) -o $(TGT) -T $(LDS) $(OBJ)
        
$(OBJ): $(SRC) $(DEP)
	$(CC) $(CFLAGS) -o $(OBJ) $(SRC)
        
$(DIS): $(TGT)
	$(DS) $(DSFLAGS) $^ > $@

$(ELF):
	$(MAKE) -C $(TOOLSPATH)

clean:
	@rm -rfv *.o *.elf *.dis *.map *.mem *_memparams*.v

