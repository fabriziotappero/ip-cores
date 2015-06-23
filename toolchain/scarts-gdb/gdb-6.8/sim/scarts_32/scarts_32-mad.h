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


#ifndef __SCARTS_32_MAD_H__
#define __SCARTS_32_MAD_H__

#include <inttypes.h>
#include "scarts_32-codemem.h"
#include "scarts_32-datamem.h"

enum scarts_mem_type
{
  SCARTS_NOMEM,
  SCARTS_BOOTMEM,
  SCARTS_CODEMEM,
  SCARTS_DATAMEM,
  SCARTS_PLUGIN
};

extern enum scarts_mem_type scarts_lma_decode (uint32_t lma,
                                               scarts_codemem_read_fptr_t *codemem_read_fptr,
                                               scarts_codemem_write_fptr_t *codemem_write_fptr,
                                               scarts_datamem_read_fptr_t *datamem_read_fptr,
                                               scarts_datamem_write_fptr_t *datamem_write_fptr,
                                               uint32_t *addr);

extern enum scarts_mem_type scarts_codemem_vma_decode (uint32_t vma,
                                                       scarts_codemem_read_fptr_t *read_fptr,
                                                       scarts_codemem_write_fptr_t *write_fptr,
                                                       uint32_t *addr);

extern enum scarts_mem_type scarts_datamem_vma_decode (uint32_t vma,
                                                       scarts_datamem_read_fptr_t *read_fptr,
                                                       scarts_datamem_write_fptr_t *write_fptr,
                                                       uint32_t *addr);

#endif

