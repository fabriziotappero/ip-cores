//////////////////////////////////////////////////////////////////////
////                                                              ////
////  dbg_comm_vpi.v                                              ////
////                                                              ////
////                                                              ////
////  This file is part of the SoC/OpenRISC Development Interface ////
////  http://www.opencores.org/cores/DebugInterface/              ////
////                                                              ////
////                                                              ////
////  Author(s):                                                  ////
////       Igor Mohor (igorm@opencores.org)                       ////
////       Gyorgy Jeney (nog@sdf.lonestar.net)                    ////
////       Nathan Yawn (nathan.yawn@opencores.org)                ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000-2008 Authors                              ////
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
// $Log: dbg_comm_vpi.v,v $
// Revision 1.2  2009-05-17 20:55:57  Nathan
// Changed email address to opencores.org
//
// Revision 1.1  2008/07/26 17:33:20  Nathan
// Added debug comm module for use with VPI / network communication.
//
// Revision 1.1  2002/03/28 19:59:54  lampret
// Added bench directory
//
// Revision 1.1.1.1  2001/11/04 18:51:07  lampret
// First import.
//
// Revision 1.3  2001/09/24 14:06:13  mohor
// Changes connected to the OpenRISC access (SPR read, SPR write).
//
// Revision 1.2  2001/09/20 10:10:30  mohor
// Working version. Few bugs fixed, comments added.
//
// Revision 1.1.1.1  2001/09/13 13:49:19  mohor
// Initial official release.
//
//
//
//
//


`define JP_PORT "4567"
`define TIMEOUT_COUNT 6'd20  // 1/2 of a TCK clock will be this many SYS_CLK ticks.  Must be less than 6 bits. 
  
  module dbg_comm_vpi (
		       SYS_CLK,
		       SYS_RSTN,
		       P_TMS, 
		       P_TCK, 
		       P_TRST, 
		       P_TDI, 
		       P_TDO
		       );

   //parameter Tp = 20;

   output    SYS_CLK;
   output    SYS_RSTN;
   output    P_TMS;
   output    P_TCK;
   output    P_TRST;
   output    P_TDI;
   input     P_TDO;

   reg 	     SYS_CLK;
   reg 	     SYS_RSTN;
   
   
   reg [4:0] memory;  // [0:0];


   wire      P_TCK;
   wire      P_TRST;
   wire      P_TDI;
   wire      P_TMS;
   wire      P_TDO;
   
   reg [3:0] in_word_r;
   reg [5:0] clk_count;
   

   // Provide the wishbone / CPU / system clock
   initial
     begin
	SYS_CLK = 1'b0;
	clk_count[5:0] <= `TIMEOUT_COUNT + 1;  // Start with the timeout clock stopped
	forever #5 SYS_CLK = ~SYS_CLK;
     end

   // Provide the system reset
   initial
     begin
	SYS_RSTN = 1'b1;
	#200 SYS_RSTN = 1'b0;
	#5000 SYS_RSTN = 1'b1;
     end
   

   // Handle commands from the upper level
   initial
     begin
	in_word_r = 5'b0;
	memory = 5'b0;
	$jp_init(`JP_PORT);
	#5500;  // Wait until reset is complete
	
	while(1)
	  begin
	     #1;
	     $jp_in(memory);  // This will not change memory[][] if no command has been sent from jp
	     if(memory[4])  // was memory[0][4]
	       begin
		  in_word_r = memory[3:0];
		  memory = memory & 4'b1111;
		  clk_count = 6'b000000;  // Reset the timeout clock in case jp wants to wait for a timeout / half TCK period
	       end
	  end
     end



   // Send the output bit to the upper layer
   always @ (P_TDO)
     begin
	$jp_out(P_TDO); 
     end


   assign P_TCK  = in_word_r[0];
   assign P_TRST = in_word_r[1];
   assign P_TDI  = in_word_r[2];
   assign P_TMS  = in_word_r[3];


   // Send timeouts / wait periods to the upper layer
   always @ (posedge SYS_CLK)
     begin
	if(clk_count < `TIMEOUT_COUNT) clk_count[5:0] = clk_count[5:0] + 1;
	else if(clk_count == `TIMEOUT_COUNT) begin
	   $jp_wait_time();
	   clk_count[5:0] = clk_count[5:0] + 1;
	end
	// else it's already timed out, don't do anything
     end 

endmodule

