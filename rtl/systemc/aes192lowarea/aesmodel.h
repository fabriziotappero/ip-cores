//////////////////////////////////////////////////////////////////////
////                                                              ////
////  AES C behavioral model                                      ////
////                                                              ////
////  This file is part of the SystemC AES                        ////
////                                                              ////
////  Description:                                                ////
////  C behavioral model used as golden model                     ////
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

SC_MODULE(aesmodel){
	
	sc_fifo_in<bool> decrypt;
	sc_fifo_in<sc_biguint<192> > aes_key_i;
	sc_fifo_in<sc_biguint<128> > aes_data_i;
	
	sc_fifo_out<sc_biguint<128> > aes_data_o;
		
    void aes_thread(){
        unsigned char aes_key[24],aes_data[16],aes_out[16];		
		sc_biguint<128> aes_data_i_var,aes_data_o_var;
		sc_biguint<192> aes_key_i_var;
		
	    aes_context ctx;	
				
		while(1){
			
			aes_data_i_var=aes_data_i.read();
			aes_key_i_var=aes_key_i.read();
				
			//Convert a sc_biguint<128> to an array of 8 char
			aes_key[0]=(sc_uint<8>)aes_key_i_var.range(191,184);aes_key[1]=(sc_uint<8>)aes_key_i_var.range(183,176);aes_key[2]=(sc_uint<8>)aes_key_i_var.range(175,168);aes_key[3]=(sc_uint<8>)aes_key_i_var.range(167,160);
			aes_key[4]=(sc_uint<8>)aes_key_i_var.range(159,152);aes_key[5]=(sc_uint<8>)aes_key_i_var.range(151,144);aes_key[6]=(sc_uint<8>)aes_key_i_var.range(143,136);aes_key[7]=(sc_uint<8>)aes_key_i_var.range(135,128);
			aes_key[8]=(sc_uint<8>)aes_key_i_var.range(127,120);aes_key[9]=(sc_uint<8>)aes_key_i_var.range(119,112);aes_key[10]=(sc_uint<8>)aes_key_i_var.range(111,104);aes_key[11]=(sc_uint<8>)aes_key_i_var.range(103,96);
			aes_key[12]=(sc_uint<8>)aes_key_i_var.range(95,88);aes_key[13]=(sc_uint<8>)aes_key_i_var.range(87,80);aes_key[14]=(sc_uint<8>)aes_key_i_var.range(79,72);aes_key[15]=(sc_uint<8>)aes_key_i_var.range(71,64);
			aes_key[16]=(sc_uint<8>)aes_key_i_var.range(63,56);aes_key[17]=(sc_uint<8>)aes_key_i_var.range(55,48);aes_key[18]=(sc_uint<8>)aes_key_i_var.range(47,40);aes_key[19]=(sc_uint<8>)aes_key_i_var.range(39,32);
			aes_key[20]=(sc_uint<8>)aes_key_i_var.range(31,24);aes_key[21]=(sc_uint<8>)aes_key_i_var.range(23,16);aes_key[22]=(sc_uint<8>)aes_key_i_var.range(15,8);aes_key[23]=(sc_uint<8>)aes_key_i_var.range(7,0);
					
			
            aes_data[0]=(sc_uint<8>)aes_data_i_var.range(127,120);aes_data[1]=(sc_uint<8>)aes_data_i_var.range(119,112);aes_data[2]=(sc_uint<8>)aes_data_i_var.range(111,104);aes_data[3]=(sc_uint<8>)aes_data_i_var.range(103,96);
			aes_data[4]=(sc_uint<8>)aes_data_i_var.range(95,88);aes_data[5]=(sc_uint<8>)aes_data_i_var.range(87,80);aes_data[6]=(sc_uint<8>)aes_data_i_var.range(79,72);aes_data[7]=(sc_uint<8>)aes_data_i_var.range(71,64);
			aes_data[8]=(sc_uint<8>)aes_data_i_var.range(63,56);aes_data[9]=(sc_uint<8>)aes_data_i_var.range(55,48);aes_data[10]=(sc_uint<8>)aes_data_i_var.range(47,40);aes_data[11]=(sc_uint<8>)aes_data_i_var.range(39,32);
			aes_data[12]=(sc_uint<8>)aes_data_i_var.range(31,24);aes_data[13]=(sc_uint<8>)aes_data_i_var.range(23,16);aes_data[14]=(sc_uint<8>)aes_data_i_var.range(15,8);aes_data[15]=(sc_uint<8>)aes_data_i_var.range(7,0);
									
			
			if(!decrypt.read()){
			  // printf("C data: %X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X\n",aes_data[0],aes_data[1],aes_data[2],aes_data[3],aes_data[4],aes_data[5],aes_data[6],aes_data[7],aes_data[8],aes_data[9],aes_data[10],aes_data[11],aes_data[12],aes_data[13],aes_data[14],aes_data[15]);
			  // printf("C key: 0x%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X\n",aes_key[0],aes_key[1],aes_key[2],aes_key[3],aes_key[4],aes_key[5],aes_key[6],aes_key[7],aes_key[8],aes_key[9],aes_key[10],aes_key[11],aes_key[12],aes_key[13],aes_key[14],aes_key[15],aes_key[16],aes_key[17],aes_key[18],aes_key[19],aes_key[20],aes_key[21],aes_key[22],aes_key[23]);
		       aes_set_key( &ctx, aes_key, 192);
			   aes_encrypt( &ctx, aes_data, aes_data );	 
			}else{
			  // cout << "Key_i: 0x" << (int)(sc_uint<32>)aes_key_i_var.range(191,160) << (int)(sc_uint<32>)aes_key_i_var.range(159,128) << (int)(sc_uint<32>)aes_key_i_var.range(127,96) << (int)(sc_uint<32>)aes_key_i_var.range(95,64) << (int)(sc_uint<32>)aes_key_i_var.range(63,32) << (int)(sc_uint<32>)aes_key_i_var.range(31,0) << endl;	  
			  // printf("C key: 0x%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X\n",aes_key[0],aes_key[1],aes_key[2],aes_key[3],aes_key[4],aes_key[5],aes_key[6],aes_key[7],aes_key[8],aes_key[9],aes_key[10],aes_key[11],aes_key[12],aes_key[13],aes_key[14],aes_key[15],aes_key[16],aes_key[17],aes_key[18],aes_key[19],aes_key[20],aes_key[21],aes_key[22],aes_key[23]);
			   aes_set_key( &ctx, aes_key, 192);
			   aes_decrypt( &ctx, aes_data, aes_data );	 
			}
			
			for(int i=0;i<16;i++)
			  aes_out[i]=aes_data[i];
			
			aes_data_o_var.range(127,120)=aes_out[0];aes_data_o_var.range(119,112)=aes_out[1];aes_data_o_var.range(111,104)=aes_out[2];aes_data_o_var.range(103,96)=aes_out[3];
			aes_data_o_var.range(95,88)=aes_out[4];aes_data_o_var.range(87,80)=aes_out[5];aes_data_o_var.range(79,72)=aes_out[6];aes_data_o_var.range(71,64)=aes_out[7];
			aes_data_o_var.range(63,56)=aes_out[8];aes_data_o_var.range(55,48)=aes_out[9];aes_data_o_var.range(47,40)=aes_out[10];aes_data_o_var.range(39,32)=aes_out[11];
			aes_data_o_var.range(31,24)=aes_out[12];aes_data_o_var.range(23,16)=aes_out[13];aes_data_o_var.range(15,8)=aes_out[14];aes_data_o_var.range(7,0)=aes_out[15];
			
		    aes_data_o.write(aes_data_o_var);
		}
	}

    
	
	SC_CTOR(aesmodel){

		SC_THREAD(aes_thread);
		
    }
};
