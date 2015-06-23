//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Main simulation file                                        ////
////                                                              ////
////  This file is part of the SystemC AES                        ////
////                                                              ////
////  Description:                                                ////
////  Connect all the modules and begin the simulation            ////
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
#include "iostream.h"
#include "aes.h"
#include "aesfunctions.h"
#include "aesmodel.h"
#include "stimulus.h"
#include "adapt.h"
#include "checker.h"
	
int sc_main(int argc, char* argv[]){
	
    sc_clock clk("clk",20);
	 
	test *t;
    aes_transactor *tr;
    aes *ae1;
	aesmodel *am1;
	adapter *ad1;
	checker *ch1;
	
	t=new test("testbench");
    tr=new aes_transactor("aes_transactor");
    am1=new aesmodel("aes_C_model");
	ae1=new aes("aes");
	ad1=new adapter("adapter");
	ch1=new checker("checker");
		
	t->transactor(*tr);
	
	sc_signal<bool> reset;
	sc_signal<bool> rt_load;
	sc_signal<bool> rt_decrypt;
	sc_signal<sc_biguint<128> > rt_data_i;
	sc_signal<sc_biguint<192> > rt_key;
		
	sc_signal<sc_biguint<128> > rt_data_o;
	sc_signal<bool> rt_ready;
	
	sc_fifo<sc_biguint<128> > rt_aes_data_ck;
	sc_fifo<sc_biguint<128> > c_aes_data_ck;
	
	sc_fifo<bool> c_decrypt;
	sc_fifo<sc_biguint<192> > c_key;
	sc_fifo<sc_biguint<128> > c_data;
	
	ch1->reset(reset);
	ch1->rt_aes_data_i(rt_aes_data_ck);
	ch1->c_aes_data_i(c_aes_data_ck);
		
	ad1->clk(clk);
	ad1->rt_ready_i(rt_ready);
	ad1->rt_aes_data_i(rt_data_o);
	ad1->rt_aes_data_o(rt_aes_data_ck);
	
	am1->decrypt(c_decrypt);
	am1->aes_key_i(c_key);
	am1->aes_data_i(c_data);
	am1->aes_data_o(c_aes_data_ck);
	
	ae1->clk(clk);
    ae1->reset(reset);	
	ae1->load_i(rt_load);
	ae1->decrypt_i(rt_decrypt);
	ae1->data_i(rt_data_i);
	ae1->key_i(rt_key);
	ae1->data_o(rt_data_o);
	ae1->ready_o(rt_ready);
	
	tr->clk(clk);
    tr->reset(reset);	
	//Ports to RT model
	tr->rt_load_o(rt_load);
	tr->rt_decrypt_o(rt_decrypt);
	tr->rt_aes_data_o(rt_data_i);
	tr->rt_aes_key_o(rt_key);
	tr->rt_aes_ready_i(rt_ready);
	//Ports to C model
	tr->c_decrypt_o(c_decrypt);
	tr->c_aes_key_o(c_key);
	tr->c_aes_data_o(c_data);	  
	
	sc_start(-1);
	
	return 0;
	  
  }
