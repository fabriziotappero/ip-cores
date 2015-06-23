//////////////////////////////////////////////////////////////////////
////                                                              ////
////  AES top file header                                         ////
////                                                              ////
////  This file is part of the SystemC AES                        ////
////                                                              ////
////  Description:                                                ////
////  AES top file header                                         ////
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
// Revision 1.4  2005/01/20 18:14:05  jcastillo
// Style changes to fit sc2v
//
// Revision 1.3  2004/08/30 14:47:18  jcastillo
// aes.h style correction
//
// Revision 1.1.1.1  2004/07/05 09:46:22  jcastillo
// First import
//



#include "systemc.h"
//Include modules
#include "subbytes.h"
#include "mixcolum.h"
#include "sbox.h"
#include "keysched.h"



SC_MODULE(aes)
{

	sc_in<bool> clk;
	sc_in<bool> reset;

	sc_in<bool> load_i;
	sc_in<bool> decrypt_i;
	sc_in<sc_biguint<128> > data_i;
	sc_in<sc_biguint<128> > key_i;

	sc_out<bool> ready_o;
	sc_out<sc_biguint<128> > data_o;

	//Output registers
	sc_signal<bool> next_ready_o;

	//To key schedule module
	sc_signal<bool> keysched_start_i;
	sc_signal<sc_uint<4> > keysched_round_i;
	sc_signal<sc_biguint<128> > keysched_last_key_i;
	sc_signal<sc_biguint<128> > keysched_new_key_o;
	sc_signal<bool> keysched_ready_o;
	sc_signal<bool> keysched_sbox_access_o;
	sc_signal<sc_uint<8> > keysched_sbox_data_o;
	sc_signal<bool> keysched_sbox_decrypt_o;

	//From mixcolums
	sc_signal<bool> mixcol_start_i;
	sc_signal<sc_biguint<128> > mixcol_data_i;
	sc_signal<bool> mixcol_ready_o;
	sc_signal<sc_biguint<128> > mixcol_data_o;

	//From subbytes
	sc_signal<bool> subbytes_start_i;
	sc_signal<sc_biguint<128> > subbytes_data_i;
	sc_signal<bool> subbytes_ready_o;
	sc_signal<sc_biguint<128> > subbytes_data_o;
	sc_signal<sc_uint<8> > subbytes_sbox_data_o;
	sc_signal<bool> subbytes_sbox_decrypt_o;

	//To SBOX
	sc_signal<sc_uint<8> > sbox_data_o;
	sc_signal<sc_uint<8> > sbox_data_i;
	sc_signal<bool> sbox_decrypt_i;

	sc_signal<sc_uint<4> > round, next_round;

        enum state_t {IDLE, ROUNDS};
	sc_signal<state_t> state, next_state;
	
	sc_signal<sc_biguint<128> > addroundkey_data_o, next_addroundkey_data_reg, addroundkey_data_reg;
	sc_signal<sc_biguint<128> > addroundkey_data_i;
	sc_signal<bool> addroundkey_ready_o, next_addroundkey_ready_o;
	sc_signal<bool> addroundkey_start_i, next_addroundkey_start_i;
	sc_signal<sc_uint<4> > addroundkey_round, next_addroundkey_round;

	sc_signal<bool> first_round_reg, next_first_round_reg;

	void registers();
	void control();
	void addroundkey();
	void sbox_muxes();

	sbox *sbox1;
	subbytes *sub1;
	mixcolum *mix1;
	keysched *ks1;


	SC_CTOR(aes)
	{

		sbox1 = new sbox("sbox");
		sub1 = new subbytes("subbytes");
		mix1 = new mixcolum("mixcolum");
		ks1 = new keysched("keysched");

		sbox1->clk(clk);
		sbox1->reset(reset);
		sbox1->data_i(sbox_data_i);
		sbox1->decrypt_i(sbox_decrypt_i);
		sbox1->data_o(sbox_data_o);

		sub1->clk(clk);
		sub1->reset(reset);
		sub1->start_i(subbytes_start_i);
		sub1->decrypt_i(decrypt_i);
		sub1->data_i(subbytes_data_i);
		sub1->ready_o(subbytes_ready_o);
		sub1->data_o(subbytes_data_o);
		sub1->sbox_data_o(subbytes_sbox_data_o);
		sub1->sbox_data_i(sbox_data_o);
		sub1->sbox_decrypt_o(subbytes_sbox_decrypt_o);

		mix1->clk(clk);
		mix1->reset(reset);
		mix1->decrypt_i(decrypt_i);
		mix1->start_i(mixcol_start_i);
		mix1->data_i(mixcol_data_i);
		mix1->ready_o(mixcol_ready_o);
		mix1->data_o(mixcol_data_o);

		ks1->clk(clk);
		ks1->reset(reset);
		ks1->start_i(keysched_start_i);
		ks1->round_i(keysched_round_i);
		ks1->last_key_i(keysched_last_key_i);
		ks1->new_key_o(keysched_new_key_o);
		ks1->ready_o(keysched_ready_o);
		ks1->sbox_access_o(keysched_sbox_access_o);
		ks1->sbox_data_o(keysched_sbox_data_o);
		ks1->sbox_data_i(sbox_data_o);
		ks1->sbox_decrypt_o(keysched_sbox_decrypt_o); //Always 0

		SC_METHOD(registers);
		sensitive_pos << clk;
		sensitive_neg << reset;

		SC_METHOD(control);
		sensitive << state << round << addroundkey_data_o << data_i << load_i;
		sensitive << decrypt_i << addroundkey_ready_o << mixcol_ready_o << subbytes_ready_o;
		sensitive << subbytes_data_o << mixcol_data_o << first_round_reg;

		SC_METHOD(addroundkey);
		sensitive << addroundkey_data_i << addroundkey_start_i << addroundkey_data_reg << addroundkey_round << keysched_new_key_o << keysched_ready_o;
		sensitive << key_i << round;

		SC_METHOD(sbox_muxes);
		sensitive << keysched_sbox_access_o << keysched_sbox_decrypt_o << keysched_sbox_data_o << subbytes_sbox_decrypt_o << subbytes_sbox_data_o;

	}
};
