//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Round of DES algorithm header                               ////
////                                                              ////
////  This file is part of the SystemC DES                        ////
////                                                              ////
////  Description:                                                ////
////  This file perform a round of the DES algorithm              ////
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
// Revision 1.1.1.1  2004/07/05 17:31:17  jcastillo
// First import
//

#include "systemc.h"

#include "key_gen.h"

SC_MODULE (desround)
{

  sc_in < bool > clk;
  sc_in < bool > reset;

  sc_in < sc_uint < 4 > >iteration_i;
  sc_in < bool > decrypt_i;
  sc_in < sc_uint < 32 > >R_i;
  sc_in < sc_uint < 32 > >L_i;
  sc_in < sc_uint < 56 > >Key_i;

  sc_out < sc_uint < 32 > >R_o;
  sc_out < sc_uint < 32 > >L_o;
  sc_out < sc_uint < 56 > >Key_o;

  sc_out < sc_uint < 6 > >s1_o, s2_o, s3_o, s4_o, s5_o, s6_o, s7_o, s8_o;
  sc_in < sc_uint < 4 > >s1_i, s2_i, s3_i, s4_i, s5_i, s6_i, s7_i, s8_i;

  void registers ();
  void round_proc ();

  sc_signal < sc_uint < 56 > >previous_key;
  sc_signal < sc_uint < 4 > >iteration;
  sc_signal < bool > decrypt;	//When decrypting we rotate rigth instead of left
  sc_signal < sc_uint < 56 > >non_perm_key;
  sc_signal < sc_uint < 48 > >new_key;

  sc_signal < sc_uint < 32 > >next_R;

  sc_signal < sc_uint < 32 > >expanRSig;

  //Round key generator
  key_gen *kg1;

  SC_CTOR (desround)
  {

    kg1 = new key_gen ("key_gen");
    kg1->previous_key (previous_key);
    kg1->iteration (iteration);
    kg1->decrypt (decrypt);
    kg1->new_key (new_key);
    kg1->non_perm_key (non_perm_key);

    SC_METHOD (registers);
    sensitive_pos << clk;
    sensitive_neg << reset;

    SC_METHOD (round_proc);
    sensitive << R_i << L_i << Key_i << iteration_i << decrypt_i;
    sensitive << new_key << s1_i << s2_i << s3_i << s4_i << s5_i;
    sensitive << s6_i << s7_i << s8_i;


  }
};
