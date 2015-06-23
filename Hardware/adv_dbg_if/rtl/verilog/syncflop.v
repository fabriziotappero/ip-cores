//////////////////////////////////////////////////////////////////////
////                                                              ////
////  syncflop.v                                                  ////
////                                                              ////
////                                                              ////
////  A generic synchronization device between two clock domains  ////
////                                                              ////
////  Author(s):                                                  ////
////       Nathan Yawn (nathan.yawn@opencores.org)                ////
////                                                              ////
////                                                              ////
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
//
// This is a synchronization element between two clock domains. It
// uses toggle signaling - that is, clock domain 1 changes the state
// of TOGGLE_IN to indicate a change, rather than setting the level
// high.  When TOGGLE_IN changes state, the output on D_OUT will be
// set to level '1', and will hold that value until D_RST is held
// high during a rising edge of DEST_CLK.  D_OUT will be updated
// on the second rising edge of DEST_CLK after the state of
// TOGGLE_IN has changed.
// RESET is asynchronous.  This is necessary to coordinate the reset
// between different clock domains with potentially different reset
// signals.
//
// Ports:
// DEST_CLK:  Clock for the target clock domain
// D_SET:     Synchronously set the output to '1'
// D_CLR:     Synchronously reset the output to '0'
// RESET:     Set all FF's to '0' (asynchronous)
// TOGGLE_IN: Toggle data signal from source clock domain
// D_OUT:     Output to clock domain 2


// Top module
module syncflop(
                DEST_CLK,
		D_SET,
		D_RST,
		RESET,
                TOGGLE_IN,
                D_OUT
		);


   input   DEST_CLK;
   input   D_SET;
   input   D_RST;
   input   RESET;
   input   TOGGLE_IN;
   output  D_OUT;

   reg 	   sync1;
   reg 	   sync2;
   reg 	   syncprev;
   reg 	   srflop;
   
   wire    syncxor;
   wire    srinput;
   wire    D_OUT;

   // Combinatorial assignments
   assign  syncxor = sync2 ^ syncprev;
   assign  srinput = syncxor | D_SET;  
   assign  D_OUT = srflop | syncxor;
 	   
   // First DFF (always enabled)
   always @ (posedge DEST_CLK or posedge RESET)
     begin
	if(RESET) sync1 <= 1'b0;
	else sync1 <= TOGGLE_IN;
     end

	   
   // Second DFF (always enabled)
   always @ (posedge DEST_CLK or posedge RESET)
     begin
	if(RESET) sync2 <= 1'b0;
	else sync2 <= sync1;
     end

	   
   // Third DFF (always enabled, used to detect toggles)
   always @ (posedge DEST_CLK or posedge RESET)
     begin
	if(RESET) syncprev <= 1'b0;
	else syncprev <= sync2;
     end

   
   // Set/Reset FF (holds detected toggles)
   always @ (posedge DEST_CLK or posedge RESET)
     begin
	if(RESET)         srflop <= 1'b0;
	else if(D_RST)    srflop <= 1'b0;
	else if (srinput) srflop <= 1'b1;
     end
   

endmodule
