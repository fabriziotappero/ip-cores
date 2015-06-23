//////////////////////////////////////////////////////////////////////
////                                                              ////
////  MD5 main simulation file                                    ////
////                                                              ////
////  This file is part of the SystemC MD5                        ////
////                                                              ////
////  Description:                                                ////
////  MD5 main simulation file                                    ////
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
#include "md5.h"
#include "stimulus.h"

int
sc_main (int argc, char *argv[])
{

  sc_clock clk ("clk", 20);

  test *t;
  md5_transactor *tr;
  md5 *md51;

  t = new test ("testbench");
  tr = new md5_transactor ("md5_transactor");
  md51 = new md5 ("md5");

  t->transactor (*tr);

  sc_signal < bool > reset;
  sc_signal < bool > load_i;
  sc_signal < bool > newtext_i;
  sc_signal < sc_biguint < 128 > >data_i;
  sc_signal < sc_biguint < 128 > >data_o;
  sc_signal < bool > ready_o;

  md51->clk (clk);
  md51->reset (reset);
  md51->load_i (load_i);
  md51->newtext_i (newtext_i);
  md51->data_i (data_i);
  md51->data_o (data_o);
  md51->ready_o (ready_o);

  tr->clk (clk);
  tr->reset (reset);
  tr->load_i (load_i);
  tr->newtext_i (newtext_i);
  tr->data_i (data_i);
  tr->data_o (data_o);
  tr->ready_o (ready_o);


  sc_trace_file *tf = sc_create_vcd_trace_file ("md5");

  sc_trace (tf, clk, "clk");
  sc_trace (tf, reset, "reset");

  sc_trace (tf, load_i, "load_i");
  sc_trace (tf, data_i, "data_i");

  sc_trace (tf, data_o, "data_o");
  sc_trace (tf, ready_o, "ready_o");

  sc_trace (tf, md51->hash_generated, "hash_generated");
  sc_trace (tf, md51->generate_hash, "generate_hash");

  sc_trace (tf, md51->round64, "round64");
  sc_trace (tf, md51->round, "round");
  sc_trace (tf, md51->message, "message");
  sc_trace (tf, md51->getdata_state, "getdata_state");

  sc_trace (tf, md51->ar, "ar");
  sc_trace (tf, md51->br, "br");
  sc_trace (tf, md51->cr, "cr");
  sc_trace (tf, md51->dr, "dr");
  sc_trace (tf, md51->t, "t");

  sc_trace (tf, md51->func_out, "func_out");

  sc_start (20, SC_US);

  sc_close_vcd_trace_file (tf);

  return 0;

}
