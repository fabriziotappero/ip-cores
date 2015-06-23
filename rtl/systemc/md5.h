//////////////////////////////////////////////////////////////////////
////                                                              ////
////  MD5 header                                                  ////
////                                                              ////
////  This file is part of the SystemC MD5                        ////
////                                                              ////
////  Description:                                                ////
////  MD5 top file header                                         ////
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

SC_MODULE (md5)
{

  sc_in < bool > clk;
  sc_in < bool > reset;

  sc_in < bool > load_i;
  sc_out < bool > ready_o;
  sc_in < bool > newtext_i;


  //Input must be padded and in little endian mode
  sc_in < sc_biguint < 128 > >data_i;
  sc_out < sc_biguint < 128 > >data_o;


  //Signals
  sc_signal < sc_uint < 32 > >ar, br, cr, dr;
  sc_signal < sc_uint < 32 > >next_ar, next_br, next_cr, next_dr;
  sc_signal < sc_uint < 32 > >A, B, C, D;
  sc_signal < sc_uint < 32 > >next_A, next_B, next_C, next_D;

  sc_signal < bool > next_ready_o;
  sc_signal < sc_biguint < 128 > >next_data_o;

  sc_signal < sc_biguint < 512 > >message, next_message;
  sc_signal < bool > generate_hash, hash_generated, next_generate_hash;

  sc_signal < sc_uint < 3 > >getdata_state, next_getdata_state;

  sc_signal < sc_uint < 2 > >round, next_round;
  sc_signal < sc_uint < 6 > >round64, next_round64;

  sc_signal < sc_uint < 44 > >t;

  sc_signal < sc_uint < 32 > >func_out;

  void md5_getdata ();
  void reg_signal ();
  void round64FSM ();
  void md5_rom ();
  void funcs ();

  SC_CTOR (md5)
  {

    SC_METHOD (reg_signal);
    sensitive_pos << clk;
    sensitive_neg << reset;

    SC_METHOD (md5_getdata);
    sensitive << newtext_i << data_i << load_i << getdata_state <<
      hash_generated << message;
    sensitive << func_out << A << B << C << D << ar << br << cr << dr <<
      generate_hash;

    SC_METHOD (round64FSM);
    sensitive << newtext_i << round << round64 << ar << br << cr << dr <<
      generate_hash << func_out;
    sensitive << getdata_state << A << B << C << D;


    SC_METHOD (md5_rom);
    sensitive << round64;

    SC_METHOD (funcs);
    sensitive << t << ar << br << cr << dr << round << message << func_out;

  }
};
