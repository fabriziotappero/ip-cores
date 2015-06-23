/* OR1K support defines
  
   Copyright (C) 2011, ORSoC AB
   Copyright (C) 2008, 2010 Embecosm Limited
  
   Contributor Julius Baxter  <julius.baxter@orsoc.se>
   Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>
  
   This file is part of Newlib.
  
   This program is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by the Free
   Software Foundation; either version 3 of the License, or (at your option)
   any later version.
  
   This program is distributed in the hope that it will be useful, but WITHOUT
   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
  
   You should have received a copy of the GNU General Public License along
   with this program.  If not, see <http://www.gnu.org/licenses/>.            */
/* -------------------------------------------------------------------------- */
/* This program is commented throughout in a fashion suitable for processing
   with Doxygen.                                                              */
/* -------------------------------------------------------------------------- */

/* This machine configuration matches the Or1ksim configuration file in this
   directory. */

#ifndef OR1K_NEWLIB_SUPPORT_DEFS__H
#define OR1K_NEWLIB_SUPPORT_DEFS__H

/*! l.nop constants */
#define NOP_NOP          0x0000      /* Normal nop instruction */
#define NOP_EXIT         0x0001      /* End of simulation, report exit status */
#define NOP_REPORT       0x0002      /* Simple report */
/*#define NOP_PRINTF       0x0003       Simprintf instruction (obsolete)*/
#define NOP_PUTC         0x0004      /* JPB: Simputc instruction */
#define NOP_CNT_RESET    0x0005	     /* Reset statistics counters */
#define NOP_GET_TICKS    0x0006	     /* JPB: Get # ticks running */
#define NOP_GET_PS       0x0007      /* JPB: Get picosecs/cycle */
#define NOP_EXIT_SILENT  0x000c      /* End of simulation, silently exit */
#define NOP_REPORT_FIRST 0x0400      /* Report with number */
#define NOP_REPORT_LAST  0x03ff      /* Report with number */

#endif
