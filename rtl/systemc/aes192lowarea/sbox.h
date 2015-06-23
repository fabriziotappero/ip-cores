//////////////////////////////////////////////////////////////////////
////                                                              ////
////  AES sboc module header                                      ////
////                                                              ////
////  This file is part of the SystemC AES                        ////
////                                                              ////
////  Description:                                                ////
////  S-box calculation calculating inverse on gallois field      ////
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

#include "systemc.h"


SC_MODULE(sbox){
  
	sc_in<bool> clk;
	sc_in<bool> reset;
	sc_in<sc_uint<8> > data_i;
	sc_in<bool> decrypt_i;
	sc_out<sc_uint<8> > data_o;
		
    void registers();	
	void first_mux();
	void end_mux();
	void inversemap();
	void mul1();
	void mul2();
	void mul3();
    void intermediate();
	void inversion();
    void sum1();
	void square1();
	void square2();
		
	//Output from inverter to mux
	sc_signal<sc_uint<8> > inva;
	
	//Elements in GF(2^4^2)
	sc_signal<sc_uint<4> > ah,al;
	//Squares of ah and al;
	sc_signal<sc_uint<4> > ah2,al2;
	//al multiplied by ah
	sc_signal<sc_uint<4> > alxh;
	//al plus ah
	sc_signal<sc_uint<4> > alph;
	//output from inverter in GF(2^4)
	sc_signal<sc_uint<4> > d;
	//output from final multipliers
	sc_signal<sc_uint<4> > ahp,alp;
	
	
    //Registers
	sc_signal<sc_uint<4> > to_invert,next_to_invert;
    sc_signal<sc_uint<4> > ah_reg,next_ah_reg,next_alph;
	
	SC_CTOR(sbox){
				
		SC_METHOD(registers);
		sensitive_pos << clk;
		sensitive_neg << reset;
		
		SC_METHOD(first_mux);
		sensitive << data_i << decrypt_i;
   	    
		SC_METHOD(end_mux);
		sensitive << decrypt_i << inva;		
		
	    SC_METHOD(inversemap);
		sensitive << alp << ahp;
	   
		SC_METHOD(mul1);
	    sensitive << ah << al;
		
		SC_METHOD(mul2);
	    sensitive << d << ah_reg;
		
		SC_METHOD(mul3);
		sensitive << d << alph;
    
		SC_METHOD(intermediate);
        sensitive << ah2 << al2 << alxh;
		
		SC_METHOD(inversion);
		sensitive << to_invert;
		
		SC_METHOD(sum1);
		sensitive << ah << al;

		SC_METHOD(square1);
	    sensitive << ah;
	
		SC_METHOD(square2);
		sensitive << al;
	}
};
