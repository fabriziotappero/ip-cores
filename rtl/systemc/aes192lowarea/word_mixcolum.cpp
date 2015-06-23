//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Mixcolumns for a 16 bit word module implementation          ////
////                                                              ////
////  This file is part of the SystemC AES                        ////
////                                                              ////
////  Description:                                                ////
////  Mixcolum for a 16 bit word                                  ////
////                                                              ////
////  To Do:                                                      ////
////   - done                                                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Javier Castillo, jcastilo@opencores.org               ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $

#include "word_mixcolum.h"

void word_mixcolum::mix(){
  sc_uint<32> outx_var, outy_var;

  outx_var.range(31, 24) = x1.read();
  outx_var.range(23, 16) = x2.read();
  outx_var.range(15, 8) = x3.read();
  outx_var.range(7, 0) = x4.read();
  outy_var.range(31, 24) = y1.read();
  outy_var.range(23, 16) = y2.read();
  outy_var.range(15, 8) = y3.read();
  outy_var.range(7, 0) = y4.read();

  outx.write(outx_var);
  outy.write(outy_var);
}

void word_mixcolum::split()
{
  sc_uint<32> in_var;

  in_var = in.read();
  a.write(in_var.range(31, 24));
  b.write(in_var.range(23, 16));
  c.write(in_var.range(15, 8));
  d.write(in_var.range(7, 0));
}
