/* SCARTS (16-bit) target-dependent code for the GNU simulator.
   Copyright 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003
   Free Software Foundation, Inc.
   Contributed by Martin Walter <mwalter@opencores.org>

   This file is part of the GNU simulators.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */


#include <string.h>
#include "gdb/sim-scarts_16.h"
#include "scarts_16-bootmem.h"

static int      is_reset;
static uint16_t bootmem[SCARTS_BOOTMEM_SIZE];

void
scarts_bootmem_init (void)
{
  /* The boot memory is initialized with the implementation of a minimal
   * bootloader which sets the program counter to SCARTS_CODEMEM_LMA by
   * a jmp INSN.
   *
   * Assembler code:
   * ldhi  r13, (SCARTS_CODEMEM_LMA >> 8) & 0xFF
   * ldliu r13, SCARTS_CODEMEM_LMA & 0xFF
   * jmp r13
   */

  bootmem[0] = (0x1 << 12) | ((SCARTS_CODEMEM_LMA >> 8) & 0xFF) << 4 | 0xD;
  bootmem[1] = (0x2 << 12) | (SCARTS_CODEMEM_LMA & 0xFF) << 4 | 0xD;
  bootmem[2] = 0xEF0D;
}

int
scarts_bootmem_read (uint16_t addr, uint16_t* value)
{
  if (addr >= SCARTS_BOOTMEM_SIZE)
    return 0;

  *value = bootmem[addr];
  return 1;
}
  
int
scarts_bootmem_write (uint16_t addr, uint16_t value)
{
  if (addr >= SCARTS_BOOTMEM_SIZE)
    return 0;

  if (is_reset == 0)
  {
    /* Make sure that the boot memory gets reset
     * before a custom program is written to it. */
    memset (bootmem, 0, sizeof (uint16_t) * SCARTS_BOOTMEM_SIZE);
    is_reset = 1;
  }

  bootmem[addr] = value;
  return 1;
}
