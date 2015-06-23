/* SCARTS 7-segment display extension module code for the GNU simulator.
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
#include "disp7seg.h"

/* Macros for machine type. */
#if defined __SCARTS_16__
  #define SCARTS_ADDR_CTYPE  uint16_t
#elif defined __SCARTS_32__
  #define SCARTS_ADDR_CTYPE  uint32_t
#else
  #error "Unsupported target machine type"
#endif

/* Macros for bit manipulations. */
#define read_bit(regfile, bitpos) (((regfile) >> (bitpos)) & 1)
#define write_bit(regfile, bitpos, value) (void)((value) ? ((regfile) |= (1 << (bitpos))) : ((regfile) &= ~(1 << (bitpos))))

static disp7seg_mem_t mem;

uint8_t*
get_mem (void)
{
  return mem.raw;
}

void
get_mem_map (SCARTS_ADDR_CTYPE* start, SCARTS_ADDR_CTYPE* size)
{
  *start = DISP7SEG_BADDR;
  *size  = DISP7SEG_SIZE;
}

uint8_t*
get_status (void)
{
  return &mem.regfile.STATUS;
}

int
mem_read (SCARTS_ADDR_CTYPE offset, uint8_t *value)
{
  if (offset >= DISP7SEG_SIZE)
    return 0;

  *value = mem.raw[offset];
  return 1;
}

int
mem_write (SCARTS_ADDR_CTYPE offset, uint8_t value)
{
  if (offset >= DISP7SEG_SIZE)
    return 0;

  mem.raw[offset] = value; 
  return 1;
}

void
reset (void)
{
  memset (mem.raw, 0, DISP7SEG_SIZE);
}

void
tick (SCARTS_ADDR_CTYPE pc)
{
  return;
}

