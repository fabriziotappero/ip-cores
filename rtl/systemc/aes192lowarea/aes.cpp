//////////////////////////////////////////////////////////////////////
////                                                              ////
////  AES Top module                                              ////
////                                                              ////
////  This file is part of the SystemC AES                        ////
////                                                              ////
////  Description:                                                ////
////  TOP module                                                  ////
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
// Revision 1.1  2005/02/14 16:18:21  jcastillo
// aes192 uploaded
//

#include "aes.h"

void aes::registers(){
	if(!reset.read()){
		state.write(IDLE);
		ready_o.write(0);
		round.write(0);
        addroundkey_round.write(0);
		addroundkey_data_reg.write(0);
		addroundkey_ready_o.write(0);
		addroundkey_start_i.write(0);
		first_round_reg.write(0);
		last_key_half.write(0);
	}else{
		state.write(next_state.read());
		ready_o.write(next_ready_o.read());
		round.write(next_round.read());
		addroundkey_round.write(next_addroundkey_round.read());
		addroundkey_data_reg.write(next_addroundkey_data_reg.read());
		addroundkey_ready_o.write(next_addroundkey_ready_o);
		first_round_reg.write(next_first_round_reg.read());
		addroundkey_start_i.write(next_addroundkey_start_i.read());
		last_key_half.write(next_last_key_half.read());
	}
}


void aes::addroundkey(){
	sc_biguint<128> data_var,round_data_var,concat;
	sc_biguint<128> key;
	sc_uint<4> one,two,three,four;
	sc_uint<13> roundvalue;
	
	one=round.read()-1;
	two=round.read()-2;
	three=round.read()-3;
	four=round.read()-4;
	
	roundvalue=0;
	roundvalue[(int)round.read()]=true;
	
	data_var=addroundkey_data_i.read();	
	round_data_var=addroundkey_data_reg.read();
	next_addroundkey_data_reg.write(addroundkey_data_reg.read());
    next_addroundkey_ready_o.write(0);
	next_addroundkey_round.write(addroundkey_round.read());
	next_last_key_half.write(last_key_half.read());
	addroundkey_data_o.write(addroundkey_data_reg.read());
	keysched_start_i.write(0);
	keysched_round_i.write(addroundkey_round.read());
	
	if(addroundkey_round.read()==1 || addroundkey_round.read()==0)
	  keysched_last_key_i.write(key_i.read());
    else
	  keysched_last_key_i.write(keysched_new_key_o.read());
	
		    
	if(round.read()==0 && addroundkey_start_i.read()){
	   //Take the input and xor them with data if round==0;
	   round_data_var=key_i.read().range(191,64)^data_var;
	   next_addroundkey_data_reg.write(round_data_var);
       next_addroundkey_ready_o.write(1);
	   next_last_key_half.write((sc_uint<64>)key_i.read().range(63,0));
	}else if(addroundkey_start_i.read() && round.read()!=0){
	   //Calculate the round i key 
	   keysched_last_key_i.write(key_i.read());	
	   keysched_start_i.write(1);
	   keysched_round_i.write(1);
	   next_addroundkey_round.write(1);
			 
	 }else if(  keysched_ready_o.read() && (  (addroundkey_round.read()==one && roundvalue[3]) 
	                                       || (addroundkey_round.read()==two && roundvalue[6]) 
	                                       || (addroundkey_round.read()==three && roundvalue[9])
	                                       || (addroundkey_round.read()==four && roundvalue[12]))){
	   round_data_var=keysched_new_key_o.read().range(191,64)^data_var;
	   next_addroundkey_data_reg.write(round_data_var);
       next_addroundkey_ready_o.write(1);
	   next_addroundkey_round.write(0);
	   next_last_key_half.write((sc_uint<64>)keysched_new_key_o.read().range(63,0));
	 }else if(  keysched_ready_o.read() && (  (addroundkey_round.read()==one && roundvalue[2])  
	                                       || (addroundkey_round.read()==two && roundvalue[5]) 
	                                       || (addroundkey_round.read()==three && roundvalue[8])
	                                       || (addroundkey_round.read()==four && roundvalue[11]))){
	   round_data_var=keysched_new_key_o.read().range(127,0)^data_var;
	   next_addroundkey_data_reg.write(round_data_var);
       next_addroundkey_ready_o.write(1);
	   next_addroundkey_round.write(0);
	   next_last_key_half.write((sc_uint<64>)keysched_new_key_o.read().range(63,0));
     }else if(  keysched_ready_o.read() && (  ((addroundkey_round.read()==one || roundvalue[1]) && (roundvalue[1] || roundvalue[4]))  
	                                       || (addroundkey_round.read()==two && roundvalue[7]) 
	                                       || (addroundkey_round.read()==three && roundvalue[10]))){
	   
	   if(round.read()==1)
	    concat.range(127,64)=(sc_uint<64>)key_i.read().range(63,0);
	   else
	    concat.range(127,64)=(sc_uint<64>)last_key_half.read();
	    
	   concat.range(63,0)=(sc_uint<64>)keysched_new_key_o.read().range(191,128);
											   
	   round_data_var=concat^data_var;
	   next_addroundkey_data_reg.write(round_data_var);
       next_addroundkey_ready_o.write(1);
	   next_addroundkey_round.write(0);
	   next_last_key_half.write((sc_uint<64>)keysched_new_key_o.read().range(63,0));
     }else if(keysched_ready_o.read()){
	   //Round key output but not the one we want
       next_addroundkey_round.write(addroundkey_round.read()+1);
	   keysched_last_key_i.write(keysched_new_key_o.read());
	   keysched_start_i.write(1);
	   keysched_round_i.write(addroundkey_round.read()+1);
	   next_last_key_half.write((sc_uint<64>)keysched_new_key_o.read().range(63,0));
    }		
}	
    
void aes::sbox_muxes(){
	
	if(keysched_sbox_access_o.read()){
		sbox_decrypt_i.write(keysched_sbox_decrypt_o.read());
		sbox_data_i.write(keysched_sbox_data_o.read());
	}else{
		sbox_decrypt_i.write(subbytes_sbox_decrypt_o.read());
        sbox_data_i.write(subbytes_sbox_data_o.read());
	}
}


void aes::control(){
    	
	next_state.write(state.read());
	next_round.write(round.read());
	data_o.write(addroundkey_data_o.read());
	next_ready_o.write(0);
	
	//To key schedule module
				
	next_first_round_reg.write(0);
	
	subbytes_data_i.write(0);
	mixcol_data_i.write(0);
	addroundkey_data_i.write(0);

	next_addroundkey_start_i.write(first_round_reg.read());
    mixcol_start_i.write((addroundkey_ready_o.read() & decrypt_i.read() & round.read()!=12) | (subbytes_ready_o.read() & !decrypt_i.read()));
    subbytes_start_i.write((addroundkey_ready_o.read() & !decrypt_i.read()) | (mixcol_ready_o.read() & decrypt_i.read()) | (addroundkey_ready_o.read() & decrypt_i.read() & round.read()==12));	
		
    if(decrypt_i.read() && round.read()!=12){
	   addroundkey_data_i.write(subbytes_data_o.read());
	   subbytes_data_i.write(mixcol_data_o.read());
       mixcol_data_i.write(addroundkey_data_o.read());
    }else if(!decrypt_i.read() && round.read()!=0){
	   addroundkey_data_i.write(mixcol_data_o.read());	
	   subbytes_data_i.write(addroundkey_data_o.read());
       mixcol_data_i.write(subbytes_data_o.read());
	}else{
	   mixcol_data_i.write(subbytes_data_o.read());
	   subbytes_data_i.write(addroundkey_data_o.read());
	   addroundkey_data_i.write(data_i.read());
    }

    switch(state.read()){
		
		case IDLE:
		   if(load_i.read()){	
			   next_state.write(ROUNDS);
			   if(decrypt_i.read())
			      next_round.write(12);
			   else
			      next_round.write(0);
			   next_first_round_reg.write(1);
		   }
		   break;
				
		case ROUNDS:
	
		    //Counter	
			if(!decrypt_i.read() && mixcol_ready_o.read()){
				next_addroundkey_start_i.write(1);
				addroundkey_data_i.write(mixcol_data_o.read());	
			    next_round.write(round.read()+1);
			}else if(decrypt_i.read() && subbytes_ready_o.read()){
				next_addroundkey_start_i.write(1);
				addroundkey_data_i.write(subbytes_data_o.read());
			    next_round.write(round.read()-1);
			}
			
			//Output
		    if((round.read()==11 && !decrypt_i.read()) || (round.read()==0 && decrypt_i.read())){
				next_addroundkey_start_i.write(0);
				mixcol_start_i.write(0);
				if(subbytes_ready_o.read()){
				  addroundkey_data_i.write(subbytes_data_o.read());
				  next_addroundkey_start_i.write(1);
				  next_round.write(round.read()+1);
				}
			}
			if((round.read()==12 && !decrypt_i.read()) || (round.read()==0 && decrypt_i.read())){
				addroundkey_data_i.write(subbytes_data_o.read());
				subbytes_start_i.write(0);
				if(addroundkey_ready_o.read()){
				  next_ready_o.write(1);
				  next_state.write(IDLE);
				  next_addroundkey_start_i.write(0);
				  next_round.write(0);
				}
			}
			
		    break;
			
		default:
			next_state.write(IDLE);
			break;
	}
}
