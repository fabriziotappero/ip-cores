//////////////////////////////////////////////////////////////////////
////                                                              ////
////  MD5 stimulus                                                ////
////                                                              ////
////  This file is part of the SystemC MD5                        ////
////                                                              ////
////  Description:                                                ////
////  MD5 stimulus file                                           ////
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

#include "stimulus.h"

void
test::tb ()
{

  transactor->resetea ();

  transactor->wait_cycles (5);
  	
  //hash of ""
  transactor->new_text ();
  transactor->hash (0x00000080, 0x0, 0x0, 0x0);
  transactor->hash (0x0, 0x0, 0x0, 0x0);
  transactor->hash (0x0, 0x0, 0x0, 0x0);
  transactor->hash (0x0, 0x0, 0x0, 0x0);

  transactor->print_result ();
	
  //hash of "a"
  transactor->new_text ();	
  transactor->hash (0x00008061, 0x0, 0x0, 0x0);
  transactor->hash (0x0, 0x0, 0x0, 0x0);
  transactor->hash (0x0, 0x0, 0x0, 0x0);
  transactor->hash (0x0, 0x0, 0x8, 0x0);

  transactor->print_result ();

  //hash of "abc"
  transactor->new_text ();
  transactor->hash (0x80636261, 0x0, 0x0, 0x0);
  transactor->hash (0x0, 0x0, 0x0, 0x0);
  transactor->hash (0x0, 0x0, 0x0, 0x0);
  transactor->hash (0x0, 0x0, 0x18, 0x0);

  transactor->print_result ();

  //hash of "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
  transactor->new_text ();
  transactor->hash (0x44434241, 0x48474645, 0x4C4B4A49, 0x504F4E4D);
  transactor->hash (0x54535251, 0x58575655, 0x62615A59, 0x66656463);
  transactor->hash (0x6A696867, 0x6E6D6C6B, 0x7271706F, 0x76757473);
  transactor->hash (0x7A797877, 0x33323130, 0x37363534, 0x00803938);

  transactor->wait_result ();	

  transactor->hash (0x0, 0x0, 0x0, 0x0);
  transactor->hash (0x0, 0x0, 0x0, 0x0);
  transactor->hash (0x0, 0x0, 0x0, 0x0);
  transactor->hash (0x0, 0x0, 0x1f0, 0x0);

  transactor->print_result ();	
  
  //hash of "1233456789012334567890123345678901233456789012334567890123345678901233456789012334567890"
  transactor->new_text ();
  transactor->hash (0x34333231, 0x38373635, 0x32313039, 0x36353433);
  transactor->hash (0x30393837, 0x34333231, 0x38373635, 0x32313039);
  transactor->hash (0x36353433, 0x30393837, 0x34333231, 0x38373635); 
  transactor->hash (0x32313039, 0x36353433, 0x30393837, 0x34333231);

  transactor->wait_result();
  
  transactor->hash (0x38373635, 0x32313039, 0x36353433, 0x30393837);
  transactor->hash (0x80, 0x0, 0x0, 0x0);
  transactor->hash (0x0, 0x0, 0x0, 0x0);
  transactor->hash (0x0, 0x0, 0x280, 0x0);

  transactor->print_result ();	



}
