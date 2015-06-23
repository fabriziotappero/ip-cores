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


#ifndef __SCARTS_32_PLUGINS_H__
#define __SCARTS_32_PLUGINS_H__

#include <inttypes.h>
#include "scarts_32-codemem.h"
#include "scarts_32-datamem.h"

#define SCARTS_MAX_INTERRUPT_NUM     15
#define SCARTS_MAX_PLUGINS           20
#define SCARTS_MAX_PLUGIN_NAME_LEN  256
#define SCARTS_MAX_PLUGIN_PATH_LEN 1024

typedef uint8_t* (*scarts_plugin_get_mem)                  (void);
typedef void     (*scarts_plugin_get_mem_map)              (uint32_t *addr,   uint32_t *size);
typedef uint8_t* (*scarts_plugin_get_status_fptr_t)        (void);
typedef int      (*scarts_plugin_mem_read_fptr_t)          (uint32_t offset, uint8_t *value);
typedef int      (*scarts_plugin_mem_write_fptr_t)         (uint32_t offset, uint8_t value);
typedef void     (*scarts_plugin_reset_fptr_t)             (void);
typedef void     (*scarts_plugin_set_codemem_read_fptr_t)  (scarts_codemem_read_fptr_t codemem_read_fptr);
typedef void     (*scarts_plugin_set_codemem_write_fptr_t) (scarts_codemem_write_fptr_t codemem_write_fptr);
typedef void     (*scarts_plugin_set_datamem_read_fptr_t)  (scarts_datamem_read_fptr_t datamem_read_fptr);
typedef void     (*scarts_plugin_set_datamem_write_fptr_t) (scarts_datamem_write_fptr_t datamem_write_fptr);
typedef void     (*scarts_plugin_tick_fptr_t)              (uint32_t pc);

typedef struct
{
  void *handle;

  /* A name for this plugin or NULL if none. */
  char  name[SCARTS_MAX_PLUGIN_NAME_LEN];

  /* The interrupt number for this plugin or -1 if none. */
  int   int_num;

  scarts_plugin_get_mem                  get_mem;
  scarts_plugin_get_mem_map              get_mem_map;
  scarts_plugin_get_status_fptr_t        get_status;
  scarts_plugin_mem_read_fptr_t          mem_read;
  scarts_plugin_mem_write_fptr_t         mem_write;
  scarts_plugin_reset_fptr_t             reset;
  scarts_plugin_set_codemem_read_fptr_t  set_codemem_read_fptr;
  scarts_plugin_set_codemem_write_fptr_t set_codemem_write_fptr;
  scarts_plugin_set_datamem_read_fptr_t  set_datamem_read_fptr;
  scarts_plugin_set_datamem_write_fptr_t set_datamem_write_fptr;
  scarts_plugin_tick_fptr_t              tick;
} scarts_plugin_t;

extern scarts_plugin_t* scarts_get_plugin             (uint32_t addr);
extern int              scarts_get_plugin_int_request (void);
extern void             scarts_load_plugins           (void);
extern void             scarts_reset_plugins          (void);
extern void             scarts_tick_plugins           (uint32_t *pc);

#endif
