<##//////////////////////////////////////////////////////////////////
////                                                             ////
////  Author: Eyal Hochberg                                      ////
////          eyal@provartec.com                                 ////
////                                                             ////
////  Downloaded from: http://www.opencores.org                  ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2010 Provartec LTD                            ////
//// www.provartec.com                                           ////
//// info@provartec.com                                          ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
//// This source file is free software; you can redistribute it  ////
//// and/or modify it under the terms of the GNU Lesser General  ////
//// Public License as published by the Free Software Foundation.////
////                                                             ////
//// This source is distributed in the hope that it will be      ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied  ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR     ////
//// PURPOSE.  See the GNU Lesser General Public License for more////
//// details. http://www.gnu.org/licenses/lgpl.html              ////
////                                                             ////
//////////////////////////////////////////////////////////////////##>

OUTFILE PREFIX_regfile.h
INCLUDE def_regfile.txt

//registers
#define PREFIX_GROUP_REGS_ADDR    0xGROUP_REGS.ADDR

//fields
LOOP RX GROUP_REGS.NUM
//register GROUP_REGS[RX]:
#define PREFIX_GROUP_REGRX_ADDR       0xGROUP_REGS[RX].ADDR
#define PREFIX_GROUP_REGRX_START      GROUP_REGRX.FIRST_BIT
#define PREFIX_GROUP_REGRX_BITS       GROUP_REGRX.WIDTH
#define PREFIX_GROUP_REGRX_MASK       0xHEX(EXPR((2^GROUP_REGRX.WIDTH-1) << GROUP_REGRX.FIRST_BIT) 32 NOPRE)

ENDLOOP RX

