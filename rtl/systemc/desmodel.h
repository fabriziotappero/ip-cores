//////////////////////////////////////////////////////////////////////
////                                                              ////
////  DES C behavioral model                                      ////
////                                                              ////
////  This file is part of the SystemC DES                        ////
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
// Revision 1.1.1.1  2004/07/05 17:31:18  jcastillo
// First import
//

#include "systemc.h"

void decrypt_des (unsigned char *block, unsigned char *block_o,
		  unsigned char *key);
void encrypt_des (unsigned char *block, unsigned char *block_o,
		  unsigned char *key);

SC_MODULE (desmodel)
{

  sc_fifo_in < bool > decrypt;
  sc_fifo_in < sc_uint < 64 > >des_key_i;
  sc_fifo_in < sc_uint < 64 > >des_data_i;

  sc_fifo_out < sc_uint < 64 > >des_data_o;

  void des_thread ()
  {
    unsigned char des_key[8], des_data[8], des_out[8];
    sc_uint < 64 > des_key_i_var, des_data_i_var, des_data_o_var;

    while (1)
      {

	des_data_i_var = des_data_i.read ();
	des_key_i_var = des_key_i.read ();

	//Convert a sc_uint<64> to an array of 8 char
	des_key[0] = des_key_i_var.range (63, 56);
	des_key[1] = des_key_i_var.range (55, 48);
	des_key[2] = des_key_i_var.range (47, 40);
	des_key[3] = des_key_i_var.range (39, 32);
	des_key[4] = des_key_i_var.range (31, 24);
	des_key[5] = des_key_i_var.range (23, 16);
	des_key[6] = des_key_i_var.range (15, 8);
	des_key[7] = des_key_i_var.range (7, 0);

	des_data[0] = des_data_i_var.range (63, 56);
	des_data[1] = des_data_i_var.range (55, 48);
	des_data[2] = des_data_i_var.range (47, 40);
	des_data[3] = des_data_i_var.range (39, 32);
	des_data[4] = des_data_i_var.range (31, 24);
	des_data[5] = des_data_i_var.range (23, 16);
	des_data[6] = des_data_i_var.range (15, 8);
	des_data[7] = des_data_i_var.range (7, 0);

	if (!decrypt.read ())
	  encrypt_des (des_data, des_out, des_key);
	else
	  decrypt_des (des_data, des_out, des_key);

	des_data_o_var.range (63, 56) = des_out[0];
	des_data_o_var.range (55, 48) = des_out[1];
	des_data_o_var.range (47, 40) = des_out[2];
	des_data_o_var.range (39, 32) = des_out[3];
	des_data_o_var.range (31, 24) = des_out[4];
	des_data_o_var.range (23, 16) = des_out[5];
	des_data_o_var.range (15, 8) = des_out[6];
	des_data_o_var.range (7, 0) = des_out[7];

	des_data_o.write (des_data_o_var);
      }
  }



  SC_CTOR (desmodel)
  {

    SC_THREAD (des_thread);

  }
};
