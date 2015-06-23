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


#ifndef __PLUGIN_BREAKPOINT_H__
#define __PLUGIN_BREAKPOINT_H__

#include <inttypes.h>
#include "modules.h"

/* Macros for counting steps in the BREAKPOINT_CONFIG_C register. */
#define BREAKPOINT_CONFIG_C_STEP_COUNT_BITMASK	0x78
#define BREAKPOINT_GET_STEP_COUNT(value)	(((value) & BREAKPOINT_CONFIG_C_STEP_COUNT_BITMASK) >> 3)
#define BREAKPOINT_SET_STEP_COUNT(value, count)	((value) = ((value) & ~BREAKPOINT_CONFIG_C_STEP_COUNT_BITMASK) | ((count) << 3))

/* Macros for counting breakpoints in the BREAKPOINT_CONFIG_C register. */
#define BREAKPOINT_CONFIG_C_BP_COUNT_BITMASK	0x7
#define BREAKPOINT_GET_BP_COUNT(value)		((value) & BREAKPOINT_CONFIG_C_BP_COUNT_BITMASK)
#define BREAKPOINT_SET_BP_COUNT(value, count)	((value) = ((value) & ~BREAKPOINT_CONFIG_C_BP_COUNT_BITMASK) | (count))

typedef union
{
  struct
  {
    uint8_t STATUS;
    uint8_t STATUS_C;
    uint8_t CONFIG;
    uint8_t CONFIG_C;
    uint8_t BP0_LO;
    uint8_t BP0_HI;
    uint8_t BP0_3RD;
    uint8_t BP0_4TH;
    uint8_t BP1_LO;
    uint8_t BP1_HI;
    uint8_t BP1_3RD;
    uint8_t BP1_4TH;
    uint8_t BP2_LO;
    uint8_t BP2_HI;
    uint8_t BP2_3RD;
    uint8_t BP2_4TH;
    uint8_t BP3_LO;
    uint8_t BP3_HI;
    uint8_t BP3_3RD;
    uint8_t BP3_4TH;
    uint8_t BP4_LO;
    uint8_t BP4_HI;
    uint8_t BP4_3RD;
    uint8_t BP4_4TH;
    uint8_t BP5_LO;
    uint8_t BP5_HI;
    uint8_t BP5_3RD;
    uint8_t BP5_4TH;
    uint8_t BP6_LO;
    uint8_t BP6_HI;
    uint8_t BP6_3RD;
    uint8_t BP6_4TH;
  } regfile;

  uint8_t raw[BREAKPOINT_SIZE];
} breakpoint_mem_t;

#endif

