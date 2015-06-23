//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores common library Module                       ////
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

// -----------------------------------------------------------------------
// Module Name      : stat_counter.v
// Company          : 
// Creation date    : 
// -----------------------------------------------------------------------
// Description      : This is the general purpose statistics counter. 
//                 
//                    
// References       : 
// ------------------------------------------------------------------------

//----------------- compiler directives -----------------------------------

// ------------------------------------------------------------------------
module stat_counter
  (
   // Clock and Reset Signals
   sys_clk,
   s_reset_n,
  
   count_inc,
   count_dec,
  
   reg_sel,
   reg_wr_data,
   reg_wr, 

   cntr_intr,
   cntrout
  
  
   ); 

parameter CWD    = 1; // Counter Width
   //-------------------- Parameters -------------------------------------

   // ------------------- Clock and Reset Signals ------------------------
   input                     sys_clk;
   input                     s_reset_n;
   input                     count_inc; // Counter Increment
   input                     count_dec; // counter decrement, assuption does not under flow
   input                     reg_sel; 
   input                     reg_wr;
   input  [CWD-1:0]          reg_wr_data;
   output                    cntr_intr;
   output [CWD-1:0]          cntrout;
   // ------------------- Register Declarations --------------------------
   reg [CWD-1:0]             reg_trig_cntr;


// ------------------- Logic Starts Here ----------------------------------



always @ (posedge sys_clk or negedge s_reset_n)
begin
   if (s_reset_n == 1'b0) begin
      reg_trig_cntr <= 'b0;
   end
   else begin
      if (reg_sel && reg_wr) begin
         reg_trig_cntr <= reg_wr_data;
      end	 
      else begin	 
         if (count_inc && count_dec)
            reg_trig_cntr <= reg_trig_cntr;
         else if (count_inc)
              reg_trig_cntr <= reg_trig_cntr + 1'b1;
         else if (count_dec)
              reg_trig_cntr <= reg_trig_cntr - 1'b1;
         else
            reg_trig_cntr <= reg_trig_cntr;
      end
   end   
end 
// only increment overflow is assumed  
// decrement underflow is not handled 
assign cntr_intr = ((reg_trig_cntr + 1) == 'h0 && count_inc) ;

assign cntrout = reg_trig_cntr;

endmodule // must_stat_counter
