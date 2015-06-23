//////////////////////////////////////////////////////////////////////
////                                                              ////
////  AES moxcolum module implementation                          ////
////                                                              ////
////  This file is part of the SystemC AES                        ////
////                                                              ////
////  Description:                                                ////
////  Mixcolum stage implementation for AES algorithm             ////
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
// Revision 1.2  2004/08/30 14:44:44  jcastillo
// Code Formater used to give better appearance to SystemC code
//
// Revision 1.1.1.1  2004/07/05 09:46:22  jcastillo
// First import
//



#include "systemc.h"
#include "word_mixcolum.h"

SC_MODULE(mixcolum)
{

	sc_in<bool> clk;
	sc_in<bool> reset;

	sc_in<bool> decrypt_i;
	sc_in<bool> start_i;
	sc_in<sc_biguint<128> > data_i;

	sc_out<bool> ready_o;
	sc_out<sc_biguint<128> > data_o;

	sc_signal<sc_biguint<128> > data_reg, next_data_reg, data_o_reg, next_data_o;
	sc_signal<bool> next_ready_o;

	void mixcol();
	void registers();
	void mux();
	void assign_data_o();

	sc_signal<sc_uint<2> > state, next_state;

	sc_signal<sc_uint<32> > outx, outy, mix_word, outmux;

	word_mixcolum *w1;

	SC_CTOR(mixcolum)
	{

		w1 = new word_mixcolum("w1");

		w1->in(mix_word);
		w1->outx(outx);
		w1->outy(outy);

		SC_METHOD(assign_data_o);
		sensitive << data_o_reg;

		SC_METHOD(mux);
		sensitive << outx << outy;

		SC_METHOD(registers);
		sensitive_pos << clk;
		sensitive_neg << reset;

		SC_METHOD(mixcol);
		sensitive << decrypt_i << start_i << state << data_reg << outmux << data_o_reg;



	}
};
