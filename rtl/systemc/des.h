//////////////////////////////////////////////////////////////////////
////                                                              ////
////  DES algorithm header                                        ////
////                                                              ////
////  This file is part of the SystemC DES                        ////
////                                                              ////
////  Description:                                                ////
////  Top file for DES algorithm                                  ////
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

#include "round.h"
//S boxes
#include "s1.h"
#include "s2.h"
#include "s3.h"
#include "s4.h"
#include "s5.h"
#include "s6.h"
#include "s7.h"
#include "s8.h"


SC_MODULE (des)
{

  sc_in < bool > clk;
  sc_in < bool > reset;

  sc_in < bool > load_i;
  sc_in < bool > decrypt_i;
  sc_in < sc_uint < 64 > >data_i;
  sc_in < sc_uint < 64 > >key_i;

  sc_out < sc_uint < 64 > >data_o;
  sc_out < bool > ready_o;

  //Registers for iteration counters
  sc_signal < sc_uint < 4 > >stage1_iter, next_stage1_iter;
  sc_signal < bool > next_ready_o;
  sc_signal < sc_uint < 64 > >next_data_o;
  sc_signal < bool > data_ready, next_data_ready;

  //Conections to desround stage1
  sc_signal < sc_uint < 32 > >stage1_L_i;
  sc_signal < sc_uint < 32 > >stage1_R_i;
  sc_signal < sc_uint < 56 > >stage1_round_key_i;

  sc_signal < sc_uint < 4 > >stage1_iteration_i;
  sc_signal < sc_uint < 32 > >stage1_R_o;
  sc_signal < sc_uint < 32 > >stage1_L_o;
  sc_signal < sc_uint < 56 > >stage1_round_key_o;

  sc_signal < sc_uint < 6 > >s1_stag1_i, s2_stag1_i, s3_stag1_i, s4_stag1_i,
    s5_stag1_i, s6_stag1_i, s7_stag1_i, s8_stag1_i;
  sc_signal < sc_uint < 4 > >s1_stag1_o, s2_stag1_o, s3_stag1_o, s4_stag1_o,
    s5_stag1_o, s6_stag1_o, s7_stag1_o, s8_stag1_o;

  void des_proc ();
  void reg_signal ();

  desround *rd1;

  s1 *sbox1;
  s2 *sbox2;
  s3 *sbox3;
  s4 *sbox4;
  s5 *sbox5;
  s6 *sbox6;
  s7 *sbox7;
  s8 *sbox8;

  SC_CTOR (des)
  {

    SC_METHOD (reg_signal);
    sensitive_pos << clk;
    sensitive_neg << reset;

    SC_METHOD (des_proc);
    sensitive << data_i << key_i << load_i << stage1_iter << data_ready;
    sensitive << stage1_L_o << stage1_R_o << stage1_round_key_o;

    rd1 = new desround ("round1");

    sbox1 = new s1 ("s1");
    sbox2 = new s2 ("s2");
    sbox3 = new s3 ("s3");
    sbox4 = new s4 ("s4");
    sbox5 = new s5 ("s5");
    sbox6 = new s6 ("s6");
    sbox7 = new s7 ("s7");
    sbox8 = new s8 ("s8");

    //For each stage in the pipe one instance
    //First stage always present
    rd1->clk (clk);
    rd1->reset (reset);
    rd1->iteration_i (stage1_iteration_i);
    rd1->decrypt_i (decrypt_i);
    rd1->R_i (stage1_R_i);
    rd1->L_i (stage1_L_i);
    rd1->Key_i (stage1_round_key_i);
    rd1->R_o (stage1_R_o);
    rd1->L_o (stage1_L_o);
    rd1->Key_o (stage1_round_key_o);
    rd1->s1_o (s1_stag1_i);
    rd1->s2_o (s2_stag1_i);
    rd1->s3_o (s3_stag1_i);
    rd1->s4_o (s4_stag1_i);
    rd1->s5_o (s5_stag1_i);
    rd1->s6_o (s6_stag1_i);
    rd1->s7_o (s7_stag1_i);
    rd1->s8_o (s8_stag1_i);
    rd1->s1_i (s1_stag1_o);
    rd1->s2_i (s2_stag1_o);
    rd1->s3_i (s3_stag1_o);
    rd1->s4_i (s4_stag1_o);
    rd1->s5_i (s5_stag1_o);
    rd1->s6_i (s6_stag1_o);
    rd1->s7_i (s7_stag1_o);
    rd1->s8_i (s8_stag1_o);

    sbox1->stage1_input (s1_stag1_i);
    sbox1->stage1_output (s1_stag1_o);

    sbox2->stage1_input (s2_stag1_i);
    sbox2->stage1_output (s2_stag1_o);

    sbox3->stage1_input (s3_stag1_i);
    sbox3->stage1_output (s3_stag1_o);

    sbox4->stage1_input (s4_stag1_i);
    sbox4->stage1_output (s4_stag1_o);

    sbox5->stage1_input (s5_stag1_i);
    sbox5->stage1_output (s5_stag1_o);

    sbox6->stage1_input (s6_stag1_i);
    sbox6->stage1_output (s6_stag1_o);

    sbox7->stage1_input (s7_stag1_i);
    sbox7->stage1_output (s7_stag1_o);

    sbox8->stage1_input (s8_stag1_i);
    sbox8->stage1_output (s8_stag1_o);

  }
};
