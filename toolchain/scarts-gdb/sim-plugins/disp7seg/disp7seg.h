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


#ifndef __PLUGIN_DISP7SEG_H__
#define __PLUGIN_DISP7SEG_H__

#include <inttypes.h>
#include "modules.h"

typedef union
{
  struct
  {
    uint8_t STATUS;
    uint8_t STATUS_C;
    uint8_t CONFIG;
    uint8_t CONFIG_C;
    uint8_t PRESC_LO;
    uint8_t PRESC_HI;
    uint8_t DISPLAY;
    uint8_t LED;
  } regfile;

  uint8_t raw[DISP7SEG_SIZE];
} disp7seg_mem_t;

#endif

