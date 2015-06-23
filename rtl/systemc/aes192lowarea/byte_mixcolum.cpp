//////////////////////////////////////////////////////////////////////
////                                                              ////
////  AES mixcolums 8 bit module implementation                   ////
////                                                              ////
////  This file is part of the SystemC AES                        ////
////                                                              ////
////  Description:                                                ////
////  Submodule of mixcolums stage implementation for             ////
///   AES algorithm                                               ////
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
// Revision 1.1  2005/02/14 11:18:31  jcastillo
// Moved
//
// Revision 1.2  2004/08/30 14:44:44  jcastillo
// Code Formater used to give better appearance to SystemC code
//
// Revision 1.1.1.1  2004/07/05 09:46:22  jcastillo
// First import
//

#include "byte_mixcolum.h"

//Aux function
sc_uint <8> byte_mixcolum::xtime(sc_uint<8> in)
{
	sc_uint<4> xtime_t;
	sc_uint<8> out;

	out.range(7, 5) = in.range(6, 4);
	xtime_t[3] = in[7]; xtime_t[2] = in[7]; xtime_t[1] = 0; xtime_t[0] = in[7];
	out.range(4, 1) = xtime_t ^ in.range(3, 0);
	out[0] = in[7];
	return out;
}

void byte_mixcolum::dataflow()
{

	sc_uint<8> w1, w2, w3, w4, w5, w6, w7, w8, outx_var;

	w1 = a.read() ^ b.read();
	w2 = a.read() ^ c.read();
	w3 = c.read() ^ d.read();

	w4 = xtime(w1);
	w5 = xtime(w3);

	w6 = w2 ^ w4 ^ w5;

	w7 = xtime(w6);
	w8 = xtime(w7);

	outx_var = b.read() ^ w3 ^ w4;
	outx.write(outx_var);
	outy.write(w8 ^ outx_var);

}
