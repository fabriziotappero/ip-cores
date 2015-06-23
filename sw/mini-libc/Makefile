# ----------------------------------------------------------------
#                                                               //
#   Makefile for the mini-libc                                  //
#                                                               //
#   This file is part of the Amber project                      //
#   http://www.opencores.org/project,amber                      //
#                                                               //
#   Description                                                 //
#   Cross-compiles the mini-libc c and assembly files           //
#   into objects for inclusion with other applications.         //
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
# Compile mini-libc

AMBER_CROSSTOOL ?= amber-crosstool-not-defined

 SRC = printf.c memcpy.c libc_asm.S
TGT  = printf
 
 OBJ = $(addsuffix .o,   $(basename $(SRC)))
  CC = $(AMBER_CROSSTOOL)-gcc

# optimize for size
OPTIMIZE = -Os
 
CFLAGS  = -c -march=armv2a -mno-thumb-interwork $(OPTIMIZE) -ffreestanding -I../include
ASFLAGS = -I../include

$(TGT): $(OBJ)
	

clean:
	@rm -rfv *.o *.elf *.dis *.map *.mem $(MMP)

