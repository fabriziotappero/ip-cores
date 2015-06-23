#------------------------------------------------------------------------------#
# Common Makefile                                                              #
#------------------------------------------------------------------------------#
# Copyright (C) 2011 Mathias Hoertnagl, mathias.hoertnagl@gmail.com            #
#                                                                              #
# This program is free software; you can redistribute it and/or modify it      #
# under the terms of the GNU General Public License as published by the Free   #
# Software Foundation; either version 3 of the License, or (at your option)    #
# any later version.                                                           #
# This program is distributed in the hope that it will be useful, but WITHOUT  #
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or        #
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for     #
# more details.                                                                #
# You should have received a copy of the GNU General Public License along with #
# this program; if not, see <http://www.gnu.org/licenses/>.                    #
#------------------------------------------------------------------------------#
TOOL_DIR = /usr/local/mips-elf/bin/mips-elf-
SRC_DIR  = ../
BIN_DIR  = $(SRC_DIR)bin/
COM_DIR  = $(SRC_DIR)common/
LIB_DIR  = $(SRC_DIR)lib/
INC_DIR  = $(SRC_DIR)lib/include/

LINK     = $(COM_DIR)bram.lds
LINK2    = $(COM_DIR)flash.lds

VPATH    = $(SRC_DIR):$(COM_DIR):$(LIB_DIR):$(INC_DIR)

CFLAGS   = -march=r3000 -c -s -O2 -nostdlib -nodefaultlibs -std=c99 -Wall -w -I$(INC_DIR)
ASFLAGS  =
ARFLAGS  = rcs
LDFLAGS  = -s -N -nodefaultlibs -nostdlib -T$(LINK) -Ttext 0 -eboot -Map mem.map
LDFLAGS2 = -s -N -nodefaultlibs -nostdlib -T$(LINK2) -Ttext 0x20000000 -estart -Map mem.map
OCPFLAGS = -I elf32-big -O binary
DMPFLAGS = --disassemble-all

GCC      = $(TOOL_DIR)gcc.exe $(CFLAGS)
AS       = $(TOOL_DIR)as.exe $(ASFLAGS)
AR       = $(TOOL_DIR)ar.exe $(ARFLAGS)
LD       = $(TOOL_DIR)ld.exe $(LDFLAGS)
LD2      = $(TOOL_DIR)ld.exe $(LDFLAGS2)
OPC      = $(TOOL_DIR)objcopy.exe $(OCPFLAGS)
DMP      = $(TOOL_DIR)objdump.exe $(DMPFLAGS)
RM       = rm
MEM      = python $(COM_DIR)vhd.py
MEM2     = python $(COM_DIR)vhd2.py
LOAD     = python $(COM_DIR)upload.py

%.o : %.c
	$(GCC) $< -o $@

%.o : %.s
	$(AS) $< -o $@

.PHONY: clean
clean :
	-@$(RM) *.o *.bin *.axf *.lst *.map