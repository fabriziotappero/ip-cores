/* SCARTS (32-bit) target-dependent code for the GNU simulator.
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


#include "gdb/sim-scarts_32.h"
#include "scarts_32-codemem.h"

static uint16_t codemem[SCARTS_CODEMEM_SIZE];

int
scarts_codemem_read (uint32_t addr, uint16_t* value)
{
  if (addr >= SCARTS_CODEMEM_SIZE)
    return 0;

  *value = codemem[addr];
  return 1;
}
  
int
scarts_codemem_write (uint32_t addr, uint16_t value)
{
  if (addr >= SCARTS_CODEMEM_SIZE)
    return 0;

  codemem[addr] = value;
  return 1;
}
