//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Checker                                                     ////
////                                                              ////
////  This file is part of the SystemC DES                        ////
////                                                              ////
////  Description:                                                ////
////  Check that the outputs from the RTL model and the C model   ////
////  used as golden model are the same                           ////
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
// Revision 1.2  2004/08/30 16:55:54  jcastillo
// Used indent command on C code
//
// Revision 1.1.1.1  2004/07/05 17:31:18  jcastillo
// First import
//


#include "systemc.h"

SC_MODULE (checker)
{

  sc_in < bool > reset;

  sc_fifo_in < sc_uint < 64 > >rt_des_data_i;
  sc_fifo_in < sc_uint < 64 > >c_des_data_i;

  void check ()
  {
    sc_uint < 64 > rt_data_var, c_data_var;

    wait (reset->posedge_event ());

    while (1)
      {
	if (reset.read ())
	  {
	    rt_data_var = rt_des_data_i.read ();
	    c_data_var = c_des_data_i.read ();
	    if (rt_data_var != c_data_var)
	      {
		cout << "Simulation mismatch: 0x" << (int) rt_data_var.range (63, 32) << (int) rt_data_var.range (31,0) << " 0x" << (int) c_data_var.range (63,32) << (int) c_data_var.range (31,0) <<" " << sc_time_stamp () << endl;
		exit (0);
	      }
	    else
	      {
		cout << "OK: 0x" << (int) rt_data_var.range (63,32) << (int)rt_data_var.range (31,0) << " 0x" << (int) c_data_var.range (63, 32) << (int) c_data_var.range (31,0) << " " << sc_time_stamp () << endl;
	      }
	  }
	else
	  wait (reset->posedge_event ());
      }
  }

  SC_CTOR (checker)
  {
    SC_THREAD (check);
  }
};
