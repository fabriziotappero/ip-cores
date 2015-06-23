//////////////////////////////////////////////////////////////////////
////                                                              ////
////  README.txt                                                  ////
////                                                              ////
////                                                              ////
////  This file is part of the SPORT Controller 		  ////
////  http://www.opencores.org/projects/sport/                    ////
////                                                              ////
////                                                              ////
////  Author(s):                                                  ////
////       Jeff Anderson                                          ////
////       jeaander@opencores.org                                 ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2013 Authors                                   ////
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
//// The SPORT protocol is developed by Analog Devices.        	  ////
//// This controller is not guaranteed to adhere to the 	  ////
//// proprietary SPORT						  ////
//// standard as developed by Analog Devices.  It was developed   ////
//// from several documents that outlined the timing and signals  ////
//// for SPORT transactions, but not from any official protocol   ////
//// definition document.					  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: $
//
//
//


The included test bench is not a real test bench and should be improved.
Fitness for use on a WB bus was simulated using bus functional models that I created.
To prove total adherence to a standard, this controller should be simulated with a uP that
uses the wishbone interface.  Additionally, successful connection of this controller to an
Analog Devices uP with a SPORT interface does not imply that this controller will successully 
connect to another Analog Devices uP.

Best regards,
  Jeff Anderson