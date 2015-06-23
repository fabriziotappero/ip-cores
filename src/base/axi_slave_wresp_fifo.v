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

OUTFILE PREFIX_wresp_fifo.v

INCLUDE def_axi_slave.txt
  
module PREFIX_wresp_fifo (PORTS);
   
   parameter                  DEPTH = 8;
      
   parameter 		      DEPTH_BITS = 
			      (DEPTH <= 2)   ? 1 :
			      (DEPTH <= 4)   ? 2 :
			      (DEPTH <= 8)   ? 3 :
			      (DEPTH <= 16)  ? 4 :
			      (DEPTH <= 32)  ? 5 :
			      (DEPTH <= 64)  ? 6 :
			      (DEPTH <= 128) ? 7 : 
			      (DEPTH <= 256) ? 8 :
			      (DEPTH <= 512) ? 9 : 0; //0 is ilegal
   
   input 		      clk;
   input 		      reset;

   input 		      AWVALID;
   input 		      AWREADY;	
   input [ADDR_BITS-1:0]      AWADDR;		      
   input 		      WVALID;
   input 		      WREADY;
   input [ID_BITS-1:0] 	      WID;
   input 		      WLAST;

   output [ID_BITS-1:0]       BID;
   output [1:0] 	      BRESP;
   input 		      BVALID;
   input 		      BREADY;
   
   output 		      empty;
   output 		      pending;
   output 		      timeout;

   
   wire 		      timeout_in;
   wire 		      timeout_out;
   wire [1:0] 		      resp_in;
   reg [ADDR_BITS-1:0] 	      SLVERR_addr  = {ADDR_BITS{1'b1}};
   reg [ADDR_BITS-1:0] 	      DECERR_addr  = {ADDR_BITS{1'b1}};
   reg [ADDR_BITS-1:0] 	      TIMEOUT_addr = {ADDR_BITS{1'b1}};

   
   wire 		      push;
   wire 		      push1;
   wire 		      pop;
   wire 		      empty;
   wire 		      full;
   wire [DEPTH_BITS:0]        fullness;

   
   reg 			      pending;

   parameter 		      RESP_SLVERR = 2'b10;
   parameter                  RESP_DECERR = 2'b11;
   
   
   assign 		      resp_in = 
			      push1 & (SLVERR_addr == AWADDR) ? RESP_SLVERR :
			      push1 & (DECERR_addr == AWADDR) ? RESP_DECERR : 2'b00;

   assign 		      timeout_in = push1 & (TIMEOUT_addr == AWADDR);
   assign 		      timeout    = timeout_out & (TIMEOUT_addr != 0);
   
   
   always @(posedge clk or posedge reset)
     if (reset)
       pending <= #1 1'b0;
     else if (BVALID & BREADY)
       pending <= #1 1'b0;
     else if (BVALID & (~BREADY))
       pending <= #1 1'b1;

	      
   
   assign 		      push1 = AWVALID & AWREADY;
   assign 		      push  = WVALID & WREADY & WLAST;
   assign 		      pop   = BVALID & BREADY;
   
   
   prgen_fifo_stub #(ID_BITS, DEPTH) 
   wresp_fifo(
	      .clk(clk),
	      .reset(reset),
	      .push(push),
	      .pop(pop),
	      .din({WID
		    }
		   ),
	      .dout({BID
		     }
		    ),
	      .fullness(fullness),
	      .empty(empty),
	      .full(full)
	      );
   
   prgen_fifo_stub #(2+1, DEPTH*2) 
   wresp_fifo1(
	      .clk(clk),
	      .reset(reset),
	      .push(push1),
	      .pop(pop),
	      .din({resp_in,
		    timeout_in
		    }
		   ),
	      .dout({BRESP,
		     timeout_out
		     }
		    ),
	      .fullness(),
	      .empty(),
	      .full()
	      );
   
   
   
   
endmodule


