/* SCARTS programmer module code for the GNU simulator.
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


#include <assert.h>
#include "programmer.h"

/* Macros for machine type. */
#if defined __SCARTS_16__
  #include "scarts_16-codemem.h"
  #include "scarts_16-datamem.h"
  #define SCARTS_ADDR_CTYPE  uint16_t
#elif defined __SCARTS_32__
  #include "scarts_32-codemem.h"
  #include "scarts_32-datamem.h"
  #define SCARTS_ADDR_CTYPE  uint32_t
#else
  #error "Unsupported target machine type"
#endif

/* Macros for accessing the memory. */
#define GET_ADDRESS()	(mem.regfile.ADDRESS_LO | (mem.regfile.ADDRESS_HI << 8) | (mem.regfile.ADDRESS_3RD << 16) | (mem.regfile.ADDRESS_4TH << 24))
#define GET_DATA()	(mem.regfile.DATA_LO | (mem.regfile.DATA_HI << 8))

/* Macros for bit manipulations. */
#define read_bit(regfile, bitpos) (((regfile) >> (bitpos)) & 1)
#define write_bit(regfile, bitpos, value) (void)((value) ? ((regfile) |= (1 << (bitpos))) : ((regfile) &= ~(1 << (bitpos))))

static programmer_mem_t             mem;

static scarts_codemem_read_fptr_t  codemem_read;
static scarts_codemem_write_fptr_t codemem_write;
static scarts_datamem_read_fptr_t  datamem_read;
static scarts_datamem_write_fptr_t datamem_write;

uint8_t*
get_mem (void)
{
  return mem.raw;
}

void
get_mem_map (SCARTS_ADDR_CTYPE* start, SCARTS_ADDR_CTYPE* size)
{
  *start = PROGRAMMER_BADDR;
  *size  = PROGRAMMER_SIZE;
}

uint8_t*
get_status (void)
{
  return &mem.regfile.STATUS;
}

int
mem_read (SCARTS_ADDR_CTYPE offset, uint8_t *value)
{
  if (offset >= PROGRAMMER_SIZE)
    return 0;

  *value = mem.raw[offset];
  return 1;
}

int
mem_write (SCARTS_ADDR_CTYPE offset, uint8_t value)
{
  if (offset >= PROGRAMMER_SIZE)
    return 0;

  mem.raw[offset] = value;
  return 1;
}

void
reset (void)
{
  write_bit (mem.regfile.CONFIG_C, PROGRAMMER_CONFIG_C_CLR, 0);
}

void
set_codemem_read_fptr (scarts_codemem_read_fptr_t codemem_read_fptr)
{
  codemem_read = codemem_read_fptr;
}

void
set_codemem_write_fptr (scarts_codemem_write_fptr_t codemem_write_fptr)
{
  codemem_write = codemem_write_fptr;
}

void
set_datamem_read_fptr (scarts_datamem_read_fptr_t datamem_read_fptr)
{
  datamem_read = datamem_read_fptr;
}

void
set_datamem_write_fptr (scarts_datamem_write_fptr_t datamem_write_fptr)
{
  datamem_write = datamem_write_fptr;
}

void
tick (SCARTS_ADDR_CTYPE pc)
{
  uint16_t data, temp;
  SCARTS_ADDR_CTYPE addr;

  /* Check if a soft-reset was triggered. */
  if (read_bit (mem.regfile.CONFIG_C, PROGRAMMER_CONFIG_C_CLR))
    return;

  /* Check if the programmer execution bit is set. */
  if (read_bit (mem.regfile.CONFIG_C, PROGRAMMER_CONFIG_C_PREXE))
  {
    addr = GET_ADDRESS ();
    data = GET_DATA ();

    /* Check if the content of the data register
     * shall be written to the code memory. */
    if (!read_bit (mem.regfile.CONFIG_C, PROGRAMMER_CONFIG_C_MEM))
    {
      codemem_write (addr, data);

      codemem_read (addr, &temp);
      assert (data == temp);
    }
    else
    {
      datamem_write (addr, (uint8_t) data);

      datamem_read (addr, (uint8_t*) &temp);
      assert ((uint8_t) data == (uint8_t) temp);
    }

    /* Unset the programmer execution bit. */
    write_bit (mem.regfile.CONFIG_C, PROGRAMMER_CONFIG_C_PREXE, 0);
  }
}

