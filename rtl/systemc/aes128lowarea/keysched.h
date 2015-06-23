//////////////////////////////////////////////////////////////////////
////                                                              ////
////  AES key schedule header                                     ////
////                                                              ////
////  This file is part of the SystemC AES                        ////
////                                                              ////
////  Description:                                                ////
////  Generate the next round key from the previous one           ////
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

SC_MODULE(keysched)
{

	sc_in<bool> clk;
	sc_in<bool> reset;

	sc_in<bool> start_i;
	sc_in<sc_uint<4> > round_i;
	sc_in<sc_biguint<128> > last_key_i;
	sc_out<sc_biguint<128> > new_key_o;
	sc_out<bool> ready_o;

	//To Sbox
	//Indicates an access to sbox to arbitrate with the subbytes stage
	sc_out<bool> sbox_access_o;
	sc_out<sc_uint<8> > sbox_data_o;
	sc_in<sc_uint<8> > sbox_data_i;
	sc_out<bool> sbox_decrypt_o; //Always 0

	void rcon();
	void generate_key();
	void registers();
	void muxes();

	sc_signal<sc_uint<3> > next_state, state;
	sc_signal<sc_uint<8> > rcon_o;
	sc_signal<sc_uint<32> > next_col, col;
	sc_signal<sc_biguint<128> > key_reg, next_key_reg;
	sc_signal<bool> next_ready_o;

	SC_CTOR(keysched)
	{

		SC_METHOD(rcon);
		sensitive << round_i;

		SC_METHOD(registers);
		sensitive_pos << clk;
		sensitive_neg << reset;

		SC_METHOD(generate_key);
		sensitive << start_i << last_key_i << sbox_data_i << state << rcon_o << col << key_reg;

	}
};
