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
#include "scarts_32-datamem.h"

static uint8_t datamem[SCARTS_DATAMEM_SIZE];

int
scarts_datamem_read (uint32_t addr, uint8_t* value)
{
  if (addr >= SCARTS_DATAMEM_SIZE)
    return 0;

  *value = datamem[addr];
  return 1;
}

int
scarts_datamem_write (uint32_t addr, uint8_t value)
{
  if (addr >= SCARTS_DATAMEM_SIZE)
    return 0;

  datamem[addr] = value;
  return 1;
}
