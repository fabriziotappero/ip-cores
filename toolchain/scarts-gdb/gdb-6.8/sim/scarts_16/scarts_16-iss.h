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


#ifndef __SCARTS_16_ISS_H__
#define __SCARTS_16_ISS_H__

#include <inttypes.h>

enum scarts_access_mode
{
  WORD,
  HWORD,
  HWORDU,
  BYTE,
  BYTEU
};

extern void     scarts_init          (void);
extern int      scarts_mem_read      (uint16_t addr, uint8_t *value);
extern int      scarts_mem_write     (uint16_t addr, uint8_t value);
extern uint16_t scarts_regfile_read  (int regno);
extern void     scarts_regfile_write (int regno, uint16_t value);
extern void     scarts_reset         (void);
extern int      scarts_tick          (void);

#endif

