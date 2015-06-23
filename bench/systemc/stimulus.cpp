//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Random stimulus generation                                  ////
////                                                              ////
////  This file is part of the SystemC DES                        ////
////                                                              ////
////  Description:                                                ////
////  DES random stimulus                                         ////
////                                                              ////
////  To Do:                                                      ////
////   - nothing                                                  ////
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
// Revision 1.2  2004/08/30 16:55:54  jcastillo
// Used indent command on C code
//
// Revision 1.1.1.1  2004/07/05 17:31:18  jcastillo
// First import
//




#include "stimulus.h"

void
test::tb ()
{

  sc_uint < 64 > des_key_var, des_data_var;
  bool decrypt_var;

  scv_random::set_global_seed (53246);

  random_generator rg ("random_generator");

  transactor->resetea ();

  while (1)
    {

      rg.des_key->next ();
      rg.des_data->next ();
      rg.decrypt->next ();


      des_data_var = *(rg.des_data);
      des_key_var = *(rg.des_key);
      decrypt_var = *(rg.decrypt);

      if (!decrypt_var)
	{
	  cout << "Encrypt: 0x" << (int) des_data_var.range (63,32) << (int)des_data_var.range (31,0) << " 0x" << (int) des_key_var.range (63,32) << (int) des_key_var.range (31,0) << " " << sc_time_stamp () << endl;
	  transactor->encrypt (des_data_var, des_key_var);
	}
      else
	{
	  cout << "Decrypt: 0x" << (int) des_data_var.range (63,32) << (int)des_data_var.range (31,0) << " 0x" << (int) des_key_var.range (63,32) << (int) des_key_var.range (31,0) << " " << sc_time_stamp () << endl;
	  transactor->decrypt (des_data_var, des_key_var);
	}
    }

}
