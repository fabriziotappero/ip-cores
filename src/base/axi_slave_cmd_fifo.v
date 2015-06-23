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

OUTFILE PREFIX_cmd_fifo.v

INCLUDE def_axi_slave.txt
  
module PREFIX_cmd_fifo (PORTS);

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
      
   input [ADDR_BITS-1:0]      AADDR;
   input [ID_BITS-1:0] 	      AID;
   input [SIZE_BITS-1:0]      ASIZE;
   input [LEN_BITS-1:0]       ALEN;
   input 		      AVALID;
   input 		      AREADY;

   input 		      VALID;
   input 		      READY;
   input 		      LAST;

   output [ADDR_BITS-1:0]     cmd_addr;
   output [ID_BITS-1:0]       cmd_id;
   output [SIZE_BITS-1:0]     cmd_size;
   output [LEN_BITS-1:0]      cmd_len;
   output [1:0] 	      cmd_resp;
   output 		      cmd_timeout;
   output 		      cmd_ready;
   output 		      cmd_empty;
   output 		      cmd_full;


   
   wire 		      push;
   wire 		      pop;
   wire  		      empty;
   wire  		      full;
   wire [DEPTH_BITS:0]        fullness;


   wire [1:0] 		      resp_in;
   wire 		      timeout_in;
   wire 		      timeout_out;
   reg [ADDR_BITS-1:0] 	      SLVERR_addr = {ADDR_BITS{1'b1}};
   reg [ADDR_BITS-1:0] 	      DECERR_addr = {ADDR_BITS{1'b1}};
   reg [ADDR_BITS-1:0] 	      TIMEOUT_addr = {ADDR_BITS{1'b1}};


   
   parameter 		      RESP_SLVERR = 2'b10;
   parameter                  RESP_DECERR = 2'b11;


   
   assign 		      resp_in = 
			      push & (SLVERR_addr == AADDR) ? RESP_SLVERR :
			      push & (DECERR_addr == AADDR) ? RESP_DECERR : 2'b00;

   assign 		      timeout_in  = push & (TIMEOUT_addr == AADDR);
   assign 		      cmd_timeout = timeout_out & (TIMEOUT_addr != 0);
   
   
   assign 		      cmd_full   = full | (DEPTH == fullness);
   assign 		      cmd_empty  = empty;
   assign 		      cmd_ready  = ~empty;
   
   assign 		      push = AVALID & AREADY;
   assign 		      pop  = VALID & READY & LAST;
   

CREATE prgen_fifo.v DEFCMD(DEFINE STUB)
   prgen_fifo_stub #(ADDR_BITS+ID_BITS+SIZE_BITS+LEN_BITS+2+1, DEPTH) 
   cmd_fifo(
	    .clk(clk),
	    .reset(reset),
	    .push(push),
	    .pop(pop),
	    .din({AADDR,
		  AID,
		  ASIZE,
		  ALEN,
		  resp_in,
		  timeout_in
		  }
		 ),
	    .dout({cmd_addr,
		   cmd_id,
		   cmd_size,
		   cmd_len,
		   cmd_resp,
		   timeout_out
		   }
		  ),
	    .fullness(fullness),
	    .empty(empty),
	    .full(full)
	    );
   
   
   
   
endmodule


