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

module toggle_sync (in_clk,
		    in_rst_n,
		    out_clk,
		    out_rst_n,
		    in,
		    out_req,
		    out_ack);
		    
   output   out_req;
   input    in_clk, in_rst_n, out_clk, out_rst_n, in, out_ack;

   reg 	    in_flag, out_flag;

   always @ (posedge in_clk or negedge in_rst_n)
      if (~in_rst_n)
	 in_flag <= 1'b0;
      else
	 in_flag <= (in) ? ~in_flag : in_flag;

   always @ (posedge out_clk or negedge out_rst_n)
      if (~out_rst_n)
	 out_flag <= 1'b0;
      else
	 out_flag <= (out_ack & out_req) ? ~out_flag : out_flag;


   wire     raw_req_pend;

   assign raw_req_pend = in_flag ^ out_flag;

   reg 	    s1_out_req, s2_out_req;
   
   always @ (posedge out_clk or negedge out_rst_n)
      if (~out_rst_n) begin
	 s1_out_req <= 1'b0;
	 s2_out_req <= 1'b0;
      end // if (~out_rst_n)
      else begin
	 s1_out_req <= ~out_ack & raw_req_pend;
	 s2_out_req <= ~out_ack & s1_out_req;
      end // else: !if(~out_rst_n)

   wire out_req;

   assign out_req = s2_out_req;

endmodule // toggle_sync

