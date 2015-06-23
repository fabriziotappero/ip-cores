//////////////////////////////////////////////////////////////////////
////                                                              ////
////  AES key schedule implementation                             ////
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

#include "keysched192.h"

//Rcon ROM
void keysched::rcon(){
	
	switch(round_i.read()){
	    case 1:
            rcon_o.write(1);
            break;
	    case 2:
            rcon_o.write(2);
            break;
	    case 3:
            rcon_o.write(4);
            break;
	    case 4:
            rcon_o.write(8);
            break;
	    case 5:
            rcon_o.write(0x10);
            break;
	    case 6:
            rcon_o.write(0x20);
            break;
	    case 7:
            rcon_o.write(0x40);
            break;
	    case 8:
            rcon_o.write(0x80);
            break;
	    case 9:
            rcon_o.write(0x1B);
            break;
	    case 10:
            rcon_o.write(0x36);
            break;
		case 11:
            rcon_o.write(0x6C);
            break;
		case 12:
            rcon_o.write(0xD8);
            break;
        default:
			rcon_o.write(0);
            break;
	}
}

void keysched::generate_key(){
	sc_biguint<384> K_var,W_var;
	sc_uint<32> col_t;
	sc_uint<24> zero;
	
	zero=0;
	
	col_t=col.read();
	W_var=0;
	
	next_state.write(state.read());
	next_col.write(col.read());
	
	next_ready_o.write(0);
	next_key_reg.write(key_reg.read());
	new_key_o.write(key_reg.read());
	
    sbox_decrypt_o.write(0);
	sbox_access_o.write(0);
	sbox_data_o.write(0);
	K_var=last_key_i.read();
    		
	switch(state.read()){
	    //Substitute the bytes while rotating them
		//Four accesses to SBox are needed
		case 0:
		  if(start_i.read()){	
			col_t=0;
		    sbox_access_o.write(1);
			sbox_data_o.write((sc_uint<8>)K_var.range(31,24));
			next_state.write(1);
		  }
		  break;
	   case 1:
		  sbox_access_o.write(1);
	      sbox_data_o.write((sc_uint<8>)K_var.range(23,16));
	      col_t.range(7,0)=sbox_data_i.read();
	      next_col.write(col_t);
		  next_state.write(2);
	      break;
	   case 2:
		  sbox_access_o.write(1);
	      sbox_data_o.write((sc_uint<8>)K_var.range(15,8));
	      col_t.range(31,24)=sbox_data_i.read();    
	      next_col.write(col_t);
		  next_state.write(3);
	      break;
	   case 3:
		  sbox_access_o.write(1);
	      sbox_data_o.write((sc_uint<8>)K_var.range(7,0));	
	      col_t.range(23,16)=sbox_data_i.read();
	      next_col.write(col_t);
	      next_state.write(4);
	      break;
	   case 4:
		  sbox_access_o.write(1);
		  col_t.range(15,8)=sbox_data_i.read();
	      next_col.write(col_t);
	   	  W_var.range(191,160)=col_t^K_var.range(191,160)^(rcon_o.read(),zero);		
	   	  W_var.range(159,128)=W_var.range(191,160)^K_var.range(159,128);		
	   	  W_var.range(127,96)=W_var.range(159,128)^K_var.range(127,96);
	      W_var.range(95,64)=W_var.range(127,96)^K_var.range(95,64);
	      W_var.range(63,32)=W_var.range(95,64)^K_var.range(63,32);
	      W_var.range(31,0)=W_var.range(63,32)^K_var.range(31,0);
          next_ready_o.write(1);
          next_key_reg.write(W_var);	   
	      next_state.write(0);
		  break;
       
       default:
		  next_state.write(0); 
	      break;
   }     
}	     

void keysched::registers(){
	if(!reset.read()){
		state.write(0);
		col.write(0);
		key_reg.write(0);
		ready_o.write(0);
    }else{
		state.write(next_state.read());	
		col.write(next_col.read());
		key_reg.write(next_key_reg.read());
		ready_o.write(next_ready_o.read());
    }
}
