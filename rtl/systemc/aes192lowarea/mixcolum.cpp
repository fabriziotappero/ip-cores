//////////////////////////////////////////////////////////////////////
////                                                              ////
////  AES mixcolum module implementation                          ////
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

#include "mixcolum.h"

void mixcolum::mux(){
	  outmux.write(decrypt_i.read() ? outy.read() : outx.read());
}

void mixcolum::mixcol(){
    sc_biguint<128> data_i_var;
	sc_uint<32> aux;
	sc_biguint<128> data_reg_var;
	
	data_i_var=data_i.read();
	data_reg_var=data_reg.read();
	next_data_reg.write(data_reg.read());
	next_state.write(state.read());
	
	mix_word.write(0);
	
	next_ready_o.write(0);
	next_data_o.write(data_o_reg.read());
		
	switch(state.read()){
	   
		case 0:
			if(start_i.read()){
			   aux=data_i_var.range(127,96);
		       mix_word.write(aux);
			   data_reg_var.range(127,96)=outmux.read();
			   next_data_reg.write(data_reg_var);
			   next_state.write(1);
			}
			break;
		case 1:
			   aux=data_i_var.range(95,64);
			   mix_word.write(aux);
		       data_reg_var.range(95,64)=outmux.read();
			   next_data_reg.write(data_reg_var);
			   next_state.write(2);
			   break;
		case 2:
			   aux=data_i_var.range(63,32);
			   mix_word.write(aux);
		       data_reg_var.range(63,32)=outmux.read();
			   next_data_reg.write(data_reg_var);
			   next_state.write(3);
			   break;
	     case 3:
			   aux=data_i_var.range(31,0);
			   mix_word.write(aux);
			   data_reg_var.range(31,0)=outmux.read();
		       next_data_o.write(data_reg_var);
			   next_ready_o.write(1);
			   next_state.write(0);
			   break;	
		 default:
			 break;
	 }			   
 }
	 
 void mixcolum::registers(){
     if(!reset.read()){
		 data_reg.write(0);
		 state.write(0);
		 ready_o.write(0);
		 data_o_reg.write(0);
	 }else{
		 data_reg.write(next_data_reg.read());
		 state.write(next_state.read());
		 ready_o.write(next_ready_o.read());
		 data_o_reg.write(next_data_o.read());
	 }
 }
 
 void mixcolum::assign_data_o(){
	 data_o.write(data_o_reg.read());
 }
