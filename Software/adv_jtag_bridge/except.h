/* except.h -- OR1K architecture specific exceptions
   
Copyright (C) 1999 Damjan Lampret, lampret@opencores.org
Copyright (C) 2008 Embecosm Limited

Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

This file is part of Or1ksim, the OpenRISC 1000 Architectural Simulator.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3 of the License, or (at your option)
any later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along
with this program.  If not, see <http://www.gnu.org/licenses/>.  
*/

/* This program is commented throughout in a fashion suitable for processing
   with Doxygen. */


#ifndef EXCEPT__H
#define EXCEPT__H


/* Package includes */
//#include "arch.h"

/* Definition of OR1K exceptions */
#define EXCEPT_NONE     0x0000
#define EXCEPT_RESET	0x0100
#define EXCEPT_BUSERR	0x0200
#define EXCEPT_DPF	0x0300
#define EXCEPT_IPF	0x0400
#define EXCEPT_TICK	0x0500
#define EXCEPT_ALIGN	0x0600
#define EXCEPT_ILLEGAL	0x0700
#define EXCEPT_INT	0x0800
#define EXCEPT_DTLBMISS	0x0900
#define EXCEPT_ITLBMISS	0x0a00
#define EXCEPT_RANGE	0x0b00
#define EXCEPT_SYSCALL	0x0c00
#define EXCEPT_FPE	0x0d00
#define EXCEPT_TRAP	0x0e00

#endif /* EXCEPT__H */
