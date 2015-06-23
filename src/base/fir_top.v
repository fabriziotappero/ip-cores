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

OUTFILE NULL

STARTDEF

SWAP.GLOBAL MODEL_NAME FIR

STARTUSER

SWAP.GLOBAL.USER PREFIX fir
  
SWAP.USER FIR(ORDER,COEFF_BITS,DIN_BITS,MAC_NUM) SRCLINE CREATE fir.v DEFCMD(SWAP CONST(ORDER) ORDER) DEFCMD(SWAP CONST(COEFF_BITS) COEFF_BITS) DEFCMD(SWAP CONST(DIN_BITS) DIN_BITS) DEFCMD(SWAP CONST(MAC_NUM) MAC_NUM) ##FIR Filters

FIR(3, 12, 8, 4)    ##parallel
FIR(3, 16, 24, 2)   ##Nserial
FIR(8, 5, 32, 3)    ##Nserial
FIR(7, 8, 32, 1)    ##Serial

ENDDEF

