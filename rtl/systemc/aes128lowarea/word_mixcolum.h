//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Word mixcolum header                                        ////
////                                                              ////
////  This file is part of the SystemC AES                        ////
////                                                              ////
////  Description:                                                ////
////  Header file for 16-bit mixcolum submodule                   ////
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
// Revision 1.3  2005/01/20 18:14:06  jcastillo
// Style changes to fit sc2v
//
// Revision 1.2  2004/08/30 14:44:44  jcastillo
// Code Formater used to give better appearance to SystemC code
//
// Revision 1.1.1.1  2004/07/05 09:46:22  jcastillo
// First import
//

#include "systemc.h"
#include "byte_mixcolum.h"

SC_MODULE(word_mixcolum)
{

	sc_in<sc_uint<32> > in;
	sc_out<sc_uint<32> > outx, outy;

	sc_signal<sc_uint<8> > a, b, c, d;
	sc_signal<sc_uint<8> > x1, x2, x3, x4, y1, y2, y3, y4;

	void split();
	void mix();
	
	byte_mixcolum *bm1;
	byte_mixcolum *bm2;
	byte_mixcolum *bm3;
	byte_mixcolum *bm4;

	SC_CTOR(word_mixcolum)
	{

		SC_METHOD(split);
		sensitive << in;
		SC_METHOD(mix);
		sensitive << x1 << x2 << x3 << x4 << y1 << y2 << y3 << y4;

		bm1 = new byte_mixcolum("bm1");
		bm2 = new byte_mixcolum("bm2");
		bm3 = new byte_mixcolum("bm3");
		bm4 = new byte_mixcolum("bm4");

		bm1->a(a);
		bm1->b(b);
		bm1->c(c);
		bm1->d(d);
		bm1->outx(x1);
		bm1->outy(y1);

		bm2->a(b);
		bm2->b(c);
		bm2->c(d);
		bm2->d(a);
		bm2->outx(x2);
		bm2->outy(y2);

		bm3->a(c);
		bm3->b(d);
		bm3->c(a);
		bm3->d(b);
		bm3->outx(x3);
		bm3->outy(y3);

		bm4->a(d);
		bm4->b(a);
		bm4->c(b);
		bm4->d(c);
		bm4->outx(x4);
		bm4->outy(y4);
	}
};
