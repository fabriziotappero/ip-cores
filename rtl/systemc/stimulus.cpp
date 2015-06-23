//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Random Number Generator Testbench                           ////
////                                                              ////
////  This file is part of the SystemC RNG project                ////
////                                                              ////
////  Description:                                                ////
////  Testbench stimulus                                          ////
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
// Revision 1.2  2004/08/30 17:01:50  jcastillo
// Used indent command
//
// Revision 1.1.1.1  2004/08/19 14:27:14  jcastillo
// First import
//

#include "systemc.h"
#include "stimulus.h"

void
stimulus::tb ()
{

  wait (clk->posedge_event ());
  reset.write (0);
  wait (clk->posedge_event ());
  reset.write (1);
  wait (clk->posedge_event ());
  loadseed_o.write (1);
  seed_o.write (0x12678);
  wait (clk->posedge_event ());
  loadseed_o.write (0);
  for (;;)
    {
      wait (clk->posedge_event ());
      cout << (unsigned int) number_i.read () << endl;
    }

}
