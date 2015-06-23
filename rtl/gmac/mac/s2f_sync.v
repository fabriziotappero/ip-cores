//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores MAC Interface Module                        ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
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
/***************************************************************
  Description:
	Synchronizes the pulse from one clock to another
 * clock domain
***********************************************************************/
//`timescale 1ns/100ps
module s2f_sync (
		   //outputs
		   sync_out_pulse,
		   //inputs
		   in_pulse,
		   dest_clk,
		   reset_n);
  
  output sync_out_pulse; //output synchronised to slow clock
  input	 in_pulse;       //input based on fast clock, pulse
  input	 dest_clk;           //slow clock
  input	 reset_n;
  
  reg	 sync1_out, sync2_out, sync3_out;
  
  always @(posedge dest_clk or negedge reset_n)
    begin
      if (!reset_n)
	begin
	  sync1_out <= 0;
	  sync2_out <= 0;
	  sync3_out <= 0;
	end // if (!reset_n)
      else
	begin
	  sync1_out <= in_pulse;
	  sync2_out <= sync1_out;
	  sync3_out <= sync2_out;
	end // else: !if(reset_n)
    end // always @ (posedge dest_clk or negedge reset_n)
  
  assign sync_out_pulse = sync2_out && !sync3_out;
endmodule // s2f_sync
  
  
  
  
  
