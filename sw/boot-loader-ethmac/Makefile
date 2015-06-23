# ----------------------------------------------------------------
#                                                               //
#   Makefile for the boot-loader application.                   //
#                                                               //
#   This file is part of the Amber project                      //
#   http://www.opencores.org/project,amber                      //
#                                                               //
#   Description                                                 //
#   Simple makefile that defines the sources and target.        //
#   Uses the common.mk common makefile script.                  //
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

SRC = boot-loader-ethmac.c line-buffer.c timer.c print.c elfsplitter.c utilities.c led.c \
      serial.c ethmac.c packet.c tcp.c udp.c tftp.c telnet.c start.S ../mini-libc/memcpy.c
DEP = address_map.h line-buffer.h  timer.h  utilities.h led.h \
      serial.h ethmac.h tcp.h udp.h telnet.h tftp.h packet.h elfsplitter.h
TGT = boot-loader-ethmac.elf
LDS = sections.lds


# Needs to fit into the boot memory on the FPGA - 8kBytes
# so size is important
MIN_SIZE      = 1
CHANGE_ADDRESS = 1

all : debug
	../tools/check_mem_size.sh $(MEM) "@000040"

include ../include/common.mk
