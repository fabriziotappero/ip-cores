//////////////////////////////////////////////////////////////////////
////                                                              ////
////  MD5 transactor                                              ////
////                                                              ////
////  This file is part of the SystemC MD5                        ////
////                                                              ////
////  Description:                                                ////
////  MD5 transactor                                              ////
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
// Revision 1.1.1.1  2004/09/08 16:24:49  jcastillo
// Initial release
//

#include "systemc.h"

class transactor_ports:public sc_module
{
public:

  // Ports
  sc_in < bool > clk;
  sc_out < bool > reset;

  sc_out < bool > load_i;
  sc_in < bool > ready_o;
  sc_out < bool > newtext_i;

  //Input must be padded and in little endian mode
  sc_out < sc_biguint < 128 > >data_i;
  sc_in < sc_biguint < 128 > >data_o;
};


class rw_task_if:virtual public sc_interface
{

public:
  //Funciones para el transactor 
  virtual void resetea (void) = 0;
  virtual void new_text (void) = 0;
  virtual void print_result (void) = 0;
  virtual void wait_result (void) = 0;
  virtual void hash (sc_uint < 32 > data_4, sc_uint < 32 > data_3,
		     sc_uint < 32 > data_2, sc_uint < 32 > data_1) = 0;
  virtual void wait_cycles (int cycles) = 0;

};


//Transactor
class md5_transactor:public rw_task_if, public transactor_ports
{

public:

  SC_CTOR (md5_transactor)
  {

    cout.unsetf (ios::dec);
    cout.setf (ios::hex);
    cout.setf (ios::showbase);

  }



  void resetea (void)
  {
    reset.write (0);
    wait (clk->posedge_event ());
    reset.write (1);
    cout << "Reseteado" << endl;
  }

  void new_text ()
  {
    newtext_i.write (1);
    wait (clk->posedge_event ());
    newtext_i.write (0);
  }

  void wait_result ()
  {
    wait (ready_o->posedge_event ());
  }

  
  void print_result ()
  {
    sc_biguint < 128 > data_o_var;

    wait (ready_o->posedge_event ());
    data_o_var = data_o.read ();
	 
    cout << "HASH: " << (int) (sc_uint < 32 >) data_o_var.range (127,96) << " " << (int) (sc_uint < 32 >) data_o_var.range (95,64) << " " << (int) (sc_uint <32 >)
  	        data_o_var.range (63,32) << " " << (int) (sc_uint <32 >) data_o_var.range (31,0) <<endl;
   	  
  }

  void hash (sc_uint < 32 > data_4, sc_uint < 32 > data_3,
	     sc_uint < 32 > data_2, sc_uint < 32 > data_1)
  {
    sc_biguint < 128 > data_t;

    wait (clk->posedge_event ());
    load_i.write (1);
    data_t.range (127, 96) = data_4;
    data_t.range (95, 64) = data_3;
    data_t.range (63, 32) = data_2;
    data_t.range (31, 0) = data_1;
    data_i.write (data_t);
    wait (clk->posedge_event ());
    load_i.write (0);

  }


  void wait_cycles (int cycles)
  {
    for (int i = 0; i < cycles; i++)
      {
	wait (clk->posedge_event ());
      }
  }

};
