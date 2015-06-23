/* SCARTS_16-specific ELF support for BFD.
   Copyright 2001 Free Software Foundation, Inc.
   Contributed by Martin Walter <mwalter@opencores.org>

This file is part of BFD, the Binary File Descriptor library.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street - Fifth Floor, Boston, MA 02110-1301, USA.  */

#ifndef _ELF_SCARTS_16_H
#define _ELF_SCARTS_16_H

#include "elf/reloc-macros.h"

/* Processor specific flags for the ELF header e_flags field. */
#define EF_SCARTS_16_MACH 0xF

/* Machine identifiers correspond to machines in archures.c. */
#define E_SCARTS_16_MACH 1

/* Relocations.  */
START_RELOC_NUMBERS (elf_scarts_16_reloc_type)
  RELOC_NUMBER (R_SCARTS_16_NONE, 0)
  RELOC_NUMBER (R_SCARTS_16_16, 1)
  RELOC_NUMBER (R_SCARTS_16_32, 2)
  RELOC_NUMBER (R_SCARTS_16_LO, 3)
  RELOC_NUMBER (R_SCARTS_16_HI, 4)
  RELOC_NUMBER (R_SCARTS_16_PCREL_10, 5)
  RELOC_NUMBER (R_SCARTS_16_GNU_VTINHERIT, 6)
  RELOC_NUMBER (R_SCARTS_16_GNU_VTENTRY, 7)
END_RELOC_NUMBERS (R_SCARTS_16_max)

#endif /* _ELF_SCARTS_16_H */
