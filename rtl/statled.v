//////////////////////////////////////////////////////////////////////
////  statled.v                                                   ////   
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

`timescale 1ns / 100ps

module statled (
    input           clk,
    input           rst,
    input  [3:0]    status,
    output          led
);

`include "statled_par.v"

reg [32:0] 	pre;            // Prescaler
reg [7:0]	bcnt;           // Bit counter
reg [15:0] 	lsr;            // LED shift register 
reg [15:0]	cr;             // Code register
reg [3:0] 	str;            // Status register
wire 		rate;           // LED rate

//--------------------------------------------------------------------
// LED rate  
//
always @(posedge clk or posedge rst)
    if (rst) 
        pre <= #tDLY 0;
    else if (rate)
        pre <= #tDLY 0;
    else
        pre <= #tDLY pre + 1;

assign rate = (pre == STATLED_PULSE_CLKCNT);

//--------------------------------------------------------------------
// Capture status inputs
//
always @(posedge clk or posedge rst)
    if (rst) 
        str <= #tDLY 0;
    else 
        str <= #tDLY status;

//--------------------------------------------------------------------
// Shift register and bit counter
//
always @(posedge clk or posedge rst)
    if (rst) 
        bcnt <= #tDLY 15;
    else if (bcnt == 16)
        bcnt <= #tDLY 0;
    else if (rate)
        bcnt <= #tDLY bcnt + 1;

always @(posedge clk or posedge rst)
    if (rst) 
        lsr <= #tDLY 0;
    else if (bcnt == 16)
        lsr <= #tDLY cr;
    else if (rate)
        lsr <= #tDLY lsr << 1;

assign led = rst? 1 : lsr[15];	

//--------------------------------------------------------------------
// Codes 
//
always @*
    case(str) 
        0: cr = CODE_50_50;           // Default code
        1: cr = CODE_ONE;             // State 1 
        2: cr = CODE_TWO;             // State 2
        3: cr = CODE_THREE;           // ....
        4: cr = CODE_FOUR;            //
        5: cr = CODE_FIVE;            //
        6: cr = CODE_SIX;             //
        
        default: cr = 0;	         
    endcase	
				 
endmodule
