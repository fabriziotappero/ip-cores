/* Open8 ELF support for BFD.
   Copyright 1999, 2000, 2004, 2006, 2010, 2011  Free Software Foundation, Inc.

   Contributed by Kirk Hays, <khays@hayshaus.com>

   This file is part of BFD, the Binary File Descriptor library.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software Foundation,
   Inc., 51 Franklin Street - Fifth Floor, Boston, MA 02110-1301, USA.  */

#ifndef _ELF_OPEN8_H
#define _ELF_OPEN8_H

#include "elf/reloc-macros.h"

/* Processor specific flags for the ELF header e_flags field.  */
#define EF_OPEN8_MACH 0x7F

/* If bit #7 is set, it is assumed that the elf file uses local symbols
   as reference for the relocations so that linker relaxation is possible.  */
#define EF_OPEN8_LINKRELAX_PREPARED 0x80

#define E_OPEN8_MACH_OPEN8_1 1

/* Relocations.  */
START_RELOC_NUMBERS (elf_open8_reloc_type)
RELOC_NUMBER (R_OPEN8_NONE,        0)
RELOC_NUMBER (R_OPEN8_32,          1)
RELOC_NUMBER (R_OPEN8_PCREL,       2)
RELOC_NUMBER (R_OPEN8_16,          3)
RELOC_NUMBER (R_OPEN8_LO8_LDI,     4)
RELOC_NUMBER (R_OPEN8_HI8_LDI,     5)
RELOC_NUMBER (R_OPEN8_LO8_LDI_NEG, 6)
RELOC_NUMBER (R_OPEN8_HI8_LDI_NEG, 7)
RELOC_NUMBER (R_OPEN8_CALL,	   8)
RELOC_NUMBER (R_OPEN8_8, 	   9)
END_RELOC_NUMBERS (R_OPEN8_max)

#endif
