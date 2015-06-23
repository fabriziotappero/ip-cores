//////////////////////////////////////////////////////////////////////
////                                                              ////
////  AES subbytes module header                                  ////
////                                                              ////
////  This file is part of the SystemC AES                        ////
////                                                              ////
////  Description:                                                ////
////  Subbytes stage header for AES algorithm                     ////
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
// Revision 1.1  2005/01/26 16:51:05  jcastillo
// New examples for 0.2.5 version
//
// Revision 1.2  2004/08/30 14:44:44  jcastillo
// Code Formater used to give better appearance to SystemC code
//
// Revision 1.1.1.1  2004/07/05 09:46:22  jcastillo
// First import
//


#include "systemc.h"

SC_MODULE(subbytes)
{

	sc_in<bool> clk;
	sc_in<bool> reset;

	sc_in<bool> start_i;
	sc_in<bool> decrypt_i;
	sc_in<sc_biguint <128> > data_i;

	sc_out<bool> ready_o;
	sc_out<sc_biguint<128> > data_o;

	//To sbox
	sc_out<sc_uint<8> > sbox_data_o;
	sc_in<sc_uint<8> > sbox_data_i;
	sc_out<bool>sbox_decrypt_o;

	void sub();
	void registers();

	sc_signal<sc_uint<5> > state, next_state;
	sc_signal<sc_biguint<128> > data_reg, next_data_reg;
	sc_signal<bool> next_ready_o;

	SC_CTOR(subbytes)
	{

		SC_METHOD(registers);
		sensitive_pos << clk;
		sensitive_neg << reset;

		SC_METHOD(sub);
		sensitive << decrypt_i << start_i << state << data_i << sbox_data_i << data_reg;

	}
};
