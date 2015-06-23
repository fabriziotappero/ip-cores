//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Random Number Generator Top Header                          ////
////                                                              ////
////  This file is part of the SystemC RNG project                ////
////                                                              ////
////  Description:                                                ////
////  Top file of random number generator                         ////
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
// Revision 1.2  2005/09/16 00:30:33  jcastillo
// no message
//
// Revision 1.1.1.1  2004/10/08 14:04:10  jcastillo
// First import
//
// Revision 1.2  2004/08/30 17:01:50  jcastillo
// Used indent command
//
// Revision 1.1.1.1  2004/08/19 14:27:14  jcastillo
// First import
//
#include "systemc.h"

SC_MODULE (rng)
{

  sc_in < bool > clk;
  sc_in < bool > reset;

  sc_in < bool > loadseed_i;
  sc_in < sc_uint < 32 > >seed_i;

  sc_out < sc_uint < 32 > >number_o;

  sc_signal < sc_uint < 43 > >LFSR_reg;
  sc_signal < sc_uint < 37 > >CASR_reg;

  SC_CTOR (rng)
  {

    SC_METHOD (CASR);
    sensitive_pos << clk;
    sensitive_neg << reset;

    SC_METHOD (LFSR);
    sensitive_pos << clk;
    sensitive_neg << reset;

    SC_METHOD (combinate);
    sensitive_pos << clk;
    sensitive_neg << reset;

  };
  void CASR ();
  void LFSR ();
  void combinate ();

};
