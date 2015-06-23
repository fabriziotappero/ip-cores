/* SCARTS (16-bit) target-dependent code for GDB, the GNU debugger.
   Copyright (C) 2006, 2007, 2008 Free Software Foundation, Inc.
   Contributed by Martin Walter <mwalter@opencores.org>

   This file is part of GDB.

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


#ifndef __SCARTS_16_TDEP_H__
#define __SCARTS_16_TDEP_H__

#include "gdb/sim-scarts_16.h"

/* SCARTS architecture specific information. */
struct gdbarch_tdep
{
  unsigned int  num_gp_regs;
  unsigned int  num_sp_regs;
  unsigned int  num_pseudo_regs;
  int           pc_regnum;
  int           fp_regnum;
  int           sp_regnum;
  int           bytes_per_word;
  int           bytes_per_address;
};

/* Byte array for the ILLOP instruction used for breakpoints. */
#define SCARTS_ILLOP_INSN_STRUCT   {0xFF, 0xFF}
/* Integer for the ILLOP instruction used for breakpoints. */
#define SCARTS_ILLOP_INSN   0xFFFF

/* Properties of the architecture. */
#define SCARTS_NUM_GP_REGS             16
#define SCARTS_NUM_SP_REGS              4
#define SCARTS_NUM_PSEUDO_REGS          0
#define SCARTS_NUM_REGS                (SCARTS_NUM_GP_REGS + SCARTS_NUM_SP_REGS)
#define SCARTS_TOTAL_NUM_REGS          (SCARTS_NUM_REGS + SCARTS_NUM_PSEUDO_REGS)
#define SCARTS_NUM_INT_VECTORS         16
#define SCARTS_NUM_EXC_VECTORS         16
#define SCARTS_NUM_VECTORS             (SCARTS_NUM_INT_VECTORS + SCARTS_NUM_EXC_VECTORS)
#define SCARTS_INSN_SIZE                2
#define SCARTS_STACK_ALIGN              SCARTS_WORD_SIZE
#define SCARTS_FRAME_RED_ZONE_SIZE   2536

/* Description of the register file. */
#define SCARTS_RET_VAL_REGNUM    0 
#define SCARTS_1ST_ARG_REGNUM    1
#define SCARTS_2ND_ARG_REGNUM    2
#define SCARTS_3RD_ARG_REGNUM    3
#define SCARTS_4TH_ARG_REGNUM    4
#define SCARTS_RTS_REGNUM       14
#define SCARTS_RTE_REGNUM       15
#define SCARTS_PC_REGNUM        16
#define SCARTS_FP_REGNUM        18
#define SCARTS_SP_REGNUM        19

#endif

