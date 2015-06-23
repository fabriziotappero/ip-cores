//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Random Number Main simulation File                          ////
////                                                              ////
////  This file is part of the SystemC RNG project                ////
////                                                              ////
////  Description:                                                ////
////  Main simulation file of random number generator             ////
////                                                              ////
////  To Do:                                                      ////
////   - nothing                                                  ////
////                                                              ////
////  Author(s):                                                  ////
////      - Javier Castillo, javier.castillo@urjc.es              ////
////                                                              ////
////  This core is provided by Universidad Rey Juan Carlos        ////
////  http://www.escet.urjc.es/~jmartine                          ////
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
// Revision 1.3  2004/08/30 17:01:50  jcastillo
// Used indent command
//
// Revision 1.2  2004/08/25 15:32:23  jcastillo
// Corrected to run under MSVC60
//
// Revision 1.1.1.1  2004/08/19 14:27:14  jcastillo
// First import
//

#include "systemc.h"
#include "stimulus.h"
#include "rng.h"

#ifdef __GNUC__
#include "iostream.h"
#endif


int
sc_main (int argc, char *argv[])
{

  sc_clock clk ("clk", 1, SC_US);

  rng *rng1;
  stimulus *st1;

  rng1 = new rng ("rng");
  st1 = new stimulus ("stimulus");

  sc_signal < bool > reset;
  sc_signal < bool > loadseed_i;
  sc_signal < sc_uint < 32 > >seed_i;
  sc_signal < sc_uint < 32 > >number_o;

  rng1->clk (clk);
  rng1->reset (reset);
  rng1->loadseed_i (loadseed_i);
  rng1->seed_i (seed_i);
  rng1->number_o (number_o);

  st1->clk (clk);
  st1->reset (reset);
  st1->loadseed_o (loadseed_i);
  st1->seed_o (seed_i);
  st1->number_i (number_o);

  sc_start (-1);

  return 0;

}
