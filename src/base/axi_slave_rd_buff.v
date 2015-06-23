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

OUTFILE PREFIX_rd_buff.v

INCLUDE def_axi_slave.txt

module PREFIX_rd_buff(PORTS);

   input 		      clk;
   input 		      reset;

   output 		      RD;
   input [DATA_BITS-1:0]      DOUT;
   
   input [LEN_BITS-1:0]       rcmd_len;
   input [LEN_BITS-1:0]       rcmd_len2;
   input [1:0] 		      rcmd_resp;
   input 		      rcmd_timeout;
   input 		      rcmd_ready;

   output 		      RVALID;
   input 		      RREADY;
   output 		      RLAST;
   output [DATA_BITS-1:0]     RDATA;
   output [1:0] 	      RRESP;
   output 		      RD_last;

   input 		      RBUSY;
   
   

   reg [LEN_BITS:0] 	      valid_counter;
   reg [LEN_BITS-1:0] 	      rd_counter;
   wire 		      cmd_pending;
   reg 			      RVALID;
   reg [1:0] 		      RRESP;
   wire 		      last_rd;
   
   
   assign 		      cmd_pending = RVALID & (~RREADY);
   
   assign 		      RDATA   = DOUT;

   
   assign 		      RD      = rcmd_ready & (~cmd_pending) & (~RBUSY) & (~rcmd_timeout);

   assign 		      RD_last = RD & (rd_counter == rcmd_len);
   
   assign 		      RLAST   = RVALID & (valid_counter == rcmd_len2 + 1'b1);


   
   always @(posedge clk or posedge reset)
     if (reset)
       RRESP <= #FFD 2'b00;
     else if (RD)
       RRESP <= #FFD rcmd_resp;
   
   always @(posedge clk or posedge reset)
     if (reset)
       RVALID <= #FFD 1'b0;
     else if (RD)
       RVALID <= #FFD 1'b1;
     else if (RVALID & RREADY)
       RVALID <= #FFD 1'b0;
   
   
   always @(posedge clk or posedge reset)
     if (reset)
       valid_counter <= #FFD {LEN_BITS+1{1'b0}};
     else if (RVALID & RREADY & RLAST & RD)
       valid_counter <= #FFD 'd1;
     else if (RVALID & RREADY & RLAST)
       valid_counter <= #FFD {LEN_BITS+1{1'b0}};
     else if (RD)
       valid_counter <= #FFD valid_counter + 1'b1;

   always @(posedge clk or posedge reset)
     if (reset)
       rd_counter <= #FFD {LEN_BITS{1'b0}};
     else if (RD_last)
       rd_counter <= #FFD {LEN_BITS{1'b0}};
     else if (RD)
       rd_counter <= #FFD rd_counter + 1'b1;

   
endmodule

   
