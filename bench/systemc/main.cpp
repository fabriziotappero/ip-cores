//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Main simulation file                                        ////
////                                                              ////
////  This file is part of the SystemC DES                        ////
////                                                              ////
////  Description:                                                ////
////  Simulation file for DES project                             ////
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


#include "systemc.h"
#include "iostream.h"
#include "des.h"
#include "desfunctions.h"
#include "desmodel.h"
#include "stimulus.h"
#include "adapt.h"
#include "checker.h"

int
sc_main (int argc, char *argv[])
{

  sc_clock clk ("clk", 20);

  test *t;
  des_transactor *tr;
  des *de1;
  desmodel *dm1;
  adapter *ad1;
  checker *ch1;

  t = new test ("testbench");
  tr = new des_transactor ("des_transactor");
  dm1 = new desmodel ("des_C_model");
  de1 = new des ("des");
  ad1 = new adapter ("adapter");
  ch1 = new checker ("checker");

  t->transactor (*tr);

  sc_signal < bool > reset;
  sc_signal < bool > rt_load;
  sc_signal < bool > rt_decrypt;
  sc_signal < sc_uint < 64 > >rt_data_i;
  sc_signal < sc_uint < 64 > >rt_key;

  sc_signal < sc_uint < 64 > >rt_data_o;
  sc_signal < bool > rt_ready;

  sc_fifo < sc_uint < 64 > >rt_des_data_ck;
  sc_fifo < sc_uint < 64 > >c_des_data_ck;

  sc_fifo < bool > c_decrypt;
  sc_fifo < sc_uint < 64 > >c_key;
  sc_fifo < sc_uint < 64 > >c_data;

  ch1->reset (reset);
  ch1->rt_des_data_i (rt_des_data_ck);
  ch1->c_des_data_i (c_des_data_ck);

  ad1->clk (clk);
  ad1->rt_ready_i (rt_ready);
  ad1->rt_des_data_i (rt_data_o);
  ad1->rt_des_data_o (rt_des_data_ck);

  dm1->decrypt (c_decrypt);
  dm1->des_key_i (c_key);
  dm1->des_data_i (c_data);
  dm1->des_data_o (c_des_data_ck);

  de1->clk (clk);
  de1->reset (reset);
  de1->load_i (rt_load);
  de1->decrypt_i (rt_decrypt);
  de1->data_i (rt_data_i);
  de1->key_i (rt_key);
  de1->data_o (rt_data_o);
  de1->ready_o (rt_ready);

  tr->clk (clk);
  tr->reset (reset);
  //Ports to RT model
  tr->rt_load_o (rt_load);
  tr->rt_decrypt_o (rt_decrypt);
  tr->rt_des_data_o (rt_data_i);
  tr->rt_des_key_o (rt_key);
  tr->rt_des_ready_i (rt_ready);
  //Ports to C model
  tr->c_decrypt_o (c_decrypt);
  tr->c_des_key_o (c_key);
  tr->c_des_data_o (c_data);

  sc_start (-1);

  return 0;

}
