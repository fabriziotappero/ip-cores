<##//////////////////////////////////////////////////////////////////
////                                                             ////
////  Author: Eyal Hochberg                                      ////
////          eyal@provartec.com                                 ////
////                                                             ////
////  Downloaded from: http://www.opencores.org                  ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2010 Provartec LTD                            ////
//// www.provartec.com                                           ////
//// info@provartec.com                                          ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
//// This source file is free software; you can redistribute it  ////
//// and/or modify it under the terms of the GNU Lesser General  ////
//// Public License as published by the Free Software Foundation.////
////                                                             ////
//// This source is distributed in the hope that it will be      ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied  ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR     ////
//// PURPOSE.  See the GNU Lesser General Public License for more////
//// details. http://www.gnu.org/licenses/lgpl.html              ////
////                                                             ////
//////////////////////////////////////////////////////////////////##>

OUTFILE PREFIX_hlast.v
INCLUDE def_ahb_matrix.txt

ITER MX   

module PREFIX_hlast (PORTS);

   input                      clk;
   input                      reset;
   
   input [1:0] 		      MMX_HTRANS;
   input  		      MMX_HREADY;
   input [2:0] 		      MMX_HBURST;
   output                     MMX_HLAST;

   
   parameter                  TRANS_IDLE   = 2'b00;
   parameter                  TRANS_BUSY   = 2'b01;
   parameter                  TRANS_NONSEQ = 2'b10;
   parameter                  TRANS_SEQ    = 2'b11;

   parameter                  BURST_SINGLE = 3'b000;
   parameter                  BURST_INCR4  = 3'b011;
   parameter                  BURST_INCR8  = 3'b101;
   parameter                  BURST_INCR16 = 3'b111;


   reg [3:0]                  MMX_count;


   assign                     MMX_HLAST = (MMX_count == 'd1) | ((MMX_HTRANS == TRANS_NONSEQ) & MMX_HREADY & (MMX_HBURST == BURST_SINGLE));

LOOP MX
   always @(posedge clk or posedge reset)
     if (reset)
       MMX_count <= #FFD 4'd15;
     else if ((MMX_HTRANS == TRANS_NONSEQ) & MMX_HREADY)
       MMX_count <= #FFD 
                          (MMX_HBURST == BURST_INCR4) ? 4'd3 :
                          (MMX_HBURST == BURST_INCR8) ? 4'd7 :
                          (MMX_HBURST == BURST_INCR16) ? 4'd15 :
                          4'd0;
     else if ((MMX_HTRANS == TRANS_SEQ) & MMX_HREADY)
       MMX_count <= #FFD MMX_count - 1'b1;

ENDLOOP MX

  
     endmodule



