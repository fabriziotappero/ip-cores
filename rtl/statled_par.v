//////////////////////////////////////////////////////////////////////
////  statled_par.v                                               ////   
////                                                              ////
////  This file is part of the Status LED module.                 ////
////  http://www.opencores.org/projects/statled/                  ////
////                                                              ////
////  Author:                                                     ////
////     -Dimitar Dimitrov, d.dimitrov@bitlocker.eu               ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2010 Authors                                   ////
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

/*********************************************************************
* Clock to ouput used in simulation
*********************************************************************/
parameter tDLY                  = 1;

/*********************************************************************
* Clock speed, MHz
*********************************************************************/
parameter STATLED_CLK           = 50_000_000;

/*********************************************************************
* LED pulse width, ms
*********************************************************************/
parameter STATLED_PULSE_MS      = 225;  

/*********************************************************************
* Number of clocks per pulse width 
*********************************************************************/    
parameter STATLED_PULSE_CLKCNT 	= STATLED_CLK/1000 * STATLED_PULSE_MS;

/*********************************************************************
* Codes  
*********************************************************************/
parameter CODE_ONE      = 16'b10_00_00_00_00_00_00_00;
parameter CODE_TWO      = 16'b10_10_00_00_00_00_00_00;
parameter CODE_THREE    = 16'b10_10_10_00_00_00_00_00;
parameter CODE_FOUR     = 16'b10_10_10_10_00_00_00_00;
parameter CODE_FIVE     = 16'b10_10_10_10_10_00_00_00;
parameter CODE_SIX      = 16'b10_10_10_10_10_10_00_00;
parameter CODE_50_50    = 16'b10_10_10_10_10_10_10_10;
