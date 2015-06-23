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


#include <stdlib.h>
#include "gdb/sim-scarts_16.h"
#include "modules.h"
#include "scarts_16-tdep.h"
#include "scarts_16-bootmem.h"
#include "scarts_16-mad.h"
#include "scarts_16-plugins.h"

enum scarts_mem_type
scarts_codemem_vma_decode (uint16_t vma,
                           scarts_codemem_read_fptr_t *read_fptr,
                           scarts_codemem_write_fptr_t *write_fptr,
                           uint16_t *addr)
{
  *addr = 0;
  *read_fptr = NULL;
  *write_fptr = NULL;

  if ((vma >= SCARTS_BOOTMEM_VMA) && (vma < SCARTS_BOOTMEM_VMA + SCARTS_BOOTMEM_SIZE * SCARTS_INSN_SIZE))
  {
    *read_fptr = &scarts_bootmem_read;
    *write_fptr = &scarts_bootmem_write;

    /* The PC counts in bytes, whereas instructions
     * are stored in chunks of SCARTS_INSN_SIZE bytes. */
    *addr = (vma - SCARTS_BOOTMEM_VMA) / SCARTS_INSN_SIZE;
    return SCARTS_BOOTMEM;
  }
  else if ((vma >= SCARTS_CODEMEM_VMA) && (vma < SCARTS_CODEMEM_VMA + SCARTS_CODEMEM_SIZE * SCARTS_INSN_SIZE))
  {
    *read_fptr = &scarts_codemem_read;
    *write_fptr = &scarts_codemem_write;

    /* The PC counts in bytes, whereas instructions
     * are stored in chunks of SCARTS_INSN_SIZE bytes. */
    *addr = (vma - SCARTS_CODEMEM_VMA) / SCARTS_INSN_SIZE;
    return SCARTS_CODEMEM;
  }
  else
    return SCARTS_NOMEM;
}

enum scarts_mem_type
scarts_datamem_vma_decode (uint16_t vma,
                           scarts_datamem_read_fptr_t *read_fptr,
                           scarts_datamem_write_fptr_t *write_fptr,
                           uint16_t *addr)
{
  uint16_t plugin_addr, plugin_size;
  scarts_plugin_t *plugin;

  *addr = 0;
  *read_fptr = NULL;
  *write_fptr = NULL;

  if ((vma >= SCARTS_DATAMEM_VMA) && (vma < SCARTS_DATAMEM_VMA + SCARTS_DATAMEM_SIZE))
  {
    *read_fptr = &scarts_datamem_read;
    *write_fptr = &scarts_datamem_write;
    *addr = vma - SCARTS_DATAMEM_VMA;
    return SCARTS_DATAMEM;
  }
  else
  {
    plugin = scarts_get_plugin (vma);
    if (plugin != NULL)
    {
      plugin->get_mem_map (&plugin_addr, &plugin_size);
      *read_fptr = plugin->mem_read;
      *write_fptr = plugin->mem_write;
      *addr = vma - plugin_addr;
      return SCARTS_PLUGIN;
    }
  }

  return SCARTS_NOMEM;
}

enum scarts_mem_type
scarts_lma_decode (uint16_t lma,
                   scarts_codemem_read_fptr_t *codemem_read_fptr,
                   scarts_codemem_write_fptr_t *codemem_write_fptr,
                   scarts_datamem_read_fptr_t *datamem_read_fptr,
                   scarts_datamem_write_fptr_t *datamem_write_fptr,
                   uint16_t *addr)
{
  uint16_t vma;

  *addr = 0;
  *codemem_read_fptr = NULL;
  *codemem_write_fptr = NULL;
  *datamem_read_fptr = NULL;
  *datamem_write_fptr = NULL;

  if (lma >= SCARTS_CODEMEM_LMA)
  {
    vma = lma - SCARTS_CODEMEM_LMA + SCARTS_CODEMEM_VMA;
    return scarts_codemem_vma_decode (vma, codemem_read_fptr, codemem_write_fptr, addr);
  }
  else
  {
    vma = lma - SCARTS_DATAMEM_LMA + SCARTS_DATAMEM_VMA;
    return scarts_datamem_vma_decode (vma, datamem_read_fptr, datamem_write_fptr, addr);
  }

  return SCARTS_NOMEM;
}

