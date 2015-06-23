/* SCARTS breakpoint extension module code for the GNU simulator.
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
#include "breakpoint.h"

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

static breakpoint_mem_t mem;

uint8_t*
get_mem (void)
{
  return mem.raw;
}

void
get_mem_map (SCARTS_ADDR_CTYPE* start, SCARTS_ADDR_CTYPE* size)
{
  *start = BREAKPOINT_BADDR;
  *size  = BREAKPOINT_SIZE;
}

uint8_t*
get_status (void)
{
  return &mem.regfile.STATUS;
}

int
mem_read (SCARTS_ADDR_CTYPE offset, uint8_t *value)
{
  if (offset >= BREAKPOINT_SIZE)
    return 0;

  *value = mem.raw[offset];
  return 1;
}

int
mem_write (SCARTS_ADDR_CTYPE offset, uint8_t value)
{
  if (offset >= BREAKPOINT_SIZE)
    return 0;

  switch (offset)
  {
    /* STATUS */
    case 0:
    /* STATUS_C */
    case 1:
      /* The STATUS and STATUS_C registers are read-only. */
      return 0;
    /* CONFIG */
    case 2:
      /* Write the BREAKPOINT_CONFIG_LOOW bit to BREAKPOINT_STATUS_LOOR. */
      write_bit (mem.regfile.STATUS, BREAKPOINT_STATUS_LOOR, read_bit (value, BREAKPOINT_CONFIG_LOOW));

      /* Check if an interrupt needs to be acknowledged. */
      if (read_bit (value, BREAKPOINT_CONFIG_INTA))
      {
        write_bit (mem.regfile.STATUS, BREAKPOINT_STATUS_INT, 0);
        write_bit (value, BREAKPOINT_CONFIG_INTA, 0);
      }

      break;
  }

  mem.raw[offset] = value;
  return 1;
}

void
reset (void)
{
  memset (mem.raw, 0, BREAKPOINT_SIZE);
}

void
tick (SCARTS_ADDR_CTYPE pc)
{
  uint8_t bp_cnt, step_cnt;
  SCARTS_ADDR_CTYPE* breakpoint;

  /* Check if an interrupt was triggered. */
  if (read_bit (mem.regfile.STATUS, BREAKPOINT_STATUS_INT))
    return;

  step_cnt = BREAKPOINT_GET_STEP_COUNT (mem.regfile.CONFIG_C);
  if (step_cnt > 0)
  {
    BREAKPOINT_SET_STEP_COUNT (mem.regfile.CONFIG_C, --step_cnt);

    if (step_cnt == 0)
      /* Trigger an interrupt. */
      write_bit (mem.regfile.STATUS, BREAKPOINT_STATUS_INT, 1);
  }
  else
  {
    bp_cnt = BREAKPOINT_GET_BP_COUNT (mem.regfile.CONFIG_C);

    breakpoint = (SCARTS_ADDR_CTYPE *) &mem.regfile.BP0_LO;
    while (bp_cnt-- > 0)
    {
#if defined __SCARTS_16__
      breakpoint += 2;
#elif defined __SCARTS_32__
      breakpoint += 1;
#endif

      if (*breakpoint == pc)
        /* Trigger an interrupt. */
        write_bit (mem.regfile.STATUS, BREAKPOINT_STATUS_INT, 1);
    }
  }
}

