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

INCLUDE def_axi2ahb.txt
OUTFILE PREFIX_rd_fifo.v

module  PREFIX_rd_fifo (PORTS);

   parameter              FIFO_LINES = EXPR(2 * 16); //double buffer of max burst
   parameter              RESP_SLVERR = 2'b10;

   input                  clk;
   input                  reset;

   port                   RGROUP_AXI_R;
   input [DATA_BITS-1:0]  HRDATA;
   input                  HREADY;
   input [1:0]            HTRANS;
   input                  HRESP;
   
   input [ID_BITS-1:0]    cmd_id;
   input                  cmd_err;
   input                  rdata_phase;
   output                 rdata_ready;
   input                  data_last;


   wire                   data_push;
   wire                   data_pop;
   wire                   data_empty;
   wire                   data_full;

   reg                    RVALID;
   
   reg [LOG2(CMD_DEPTH):0] burst_cnt;

   wire                   axi_last;
   wire                   ahb_last;
   wire [1:0]             cmd_resp;

   
   assign                 cmd_resp = cmd_err | HRESP ? RESP_SLVERR : 2'b00;
   
   assign                 rdata_ready = burst_cnt < 'd2;
   
   assign                 data_push = rdata_phase & HREADY;
   assign                 data_pop = RVALID & RREADY;
   
   assign                 axi_last = RVALID & RREADY & RLAST;
   assign                 ahb_last = rdata_phase & data_last;
   
   always @(posedge clk or posedge reset)
     if (reset)
       burst_cnt <= #FFD 'd0;
     else if (axi_last | ahb_last)
       burst_cnt <= #FFD burst_cnt - axi_last + ahb_last;
   
   prgen_fifo #(DATA_BITS+ID_BITS+2+1, FIFO_LINES) 
   data_fifo(
	    .clk(clk),
	    .reset(reset),
	    .push(data_push),
	    .pop(data_pop),
	    .din({HRDATA,
                  cmd_id,
                  cmd_resp,
                  ahb_last
		  }
		 ),
	    .dout({RDATA,
                   RID,
                   RRESP,
                   RLAST
		   }
		  ),
	    .empty(data_empty),
	    .full(data_full)
	    );


   always @(posedge clk or posedge reset)
     if (reset)
       RVALID <= #FFD 1'b0;
     else if (axi_last)
       RVALID <= #FFD 1'b0;
     else if (burst_cnt > 'd0)
       RVALID <= #FFD 1'b1;
     else
       RVALID <= #FFD 1'b0;
   

endmodule

   
