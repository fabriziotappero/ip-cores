//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Random testbench stimulus generation                        ////
////                                                              ////
////  This file is part of the SystemC AES                        ////
////                                                              ////
////  Description:                                                ////
////  Generate random stimulus to the core                        ////
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

#include "stimulus.h"  

void test::tb(){
  
  sc_biguint<192> aes_key_var;
  sc_biguint<128> aes_data_var;
	
  bool decrypt_var;
   
  scv_random::set_global_seed(12659);
  
  random_generator rg("random_generator");	
 	
  transactor->resetea();
	
  while(1){
    
	rg.aes_key->next();
	rg.aes_data->next();
	rg.decrypt->next();	  
	
	  
	aes_data_var=*(rg.aes_data);
	aes_key_var=*(rg.aes_key);
    decrypt_var=*(rg.decrypt);
			  
	if(!decrypt_var){
	  transactor->encrypt(aes_data_var,aes_key_var);
	}else{
	  transactor->decrypt(aes_data_var,aes_key_var);	  
	}
  }	
	
}
