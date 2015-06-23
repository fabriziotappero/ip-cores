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
OUTFILE PREFIX_wr_fifo.v

module  PREFIX_wr_fifo (PORTS);

   parameter              FIFO_LINES = EXPR(2 * 16); //double buffer of max burst
   parameter              RESP_SLVERR = 2'b10;

   input                  clk;
   input                  reset;

   port                   WGROUP_AXI_W;
   port                   BGROUP_AXI_B;
   output [DATA_BITS-1:0] HWDATA;
   input                  HREADY;
   input [1:0]            HTRANS;
   input                  HRESP;

   input                  cmd_err;
   input                  wdata_phase;
   output                 wdata_ready;
   input                  data_last;


   wire                   data_push;
   wire                   data_pop;
   wire                   data_empty;
   wire                   data_full;

   wire                   resp_push;
   wire                   resp_pop;
   wire                   resp_empty;
   wire                   resp_full;
   
   reg [LOG2(CMD_DEPTH):0] burst_cnt;
   wire                    burst_full;
   
   wire                   axi_last;
   wire                   ahb_last;
   wire [1:0]             cmd_resp;

   assign                 cmd_resp = cmd_err | HRESP ? RESP_SLVERR : 2'b00;

   assign                 wdata_ready = burst_cnt > 'd0;
   
   assign                 WREADY = (~data_full) & (~burst_full);
   
   
   assign                 data_push = WVALID & WREADY;
   assign                 data_pop = wdata_phase & HREADY;
   
   assign                 axi_last = WVALID & WREADY & WLAST;
   assign                 ahb_last = wdata_phase & data_last;

   assign                 burst_full = burst_cnt == {EXPR(LOG2(CMD_DEPTH)+1){1'b1}};
   
   always @(posedge clk or posedge reset)
     if (reset)
       burst_cnt <= #FFD 'd0;
     else if (axi_last | ahb_last)
       burst_cnt <= #FFD burst_cnt + axi_last - ahb_last;
   
   prgen_fifo #(DATA_BITS, FIFO_LINES) 
   data_fifo(
	    .clk(clk),
	    .reset(reset),
	    .push(data_push),
	    .pop(data_pop),
	    .din({WDATA
		  }
		 ),
	    .dout({HWDATA
		   }
		  ),
	    .empty(data_empty),
	    .full(data_full)
	    );


   assign                 resp_push = ahb_last;
   assign                 resp_pop  = BVALID & BREADY;

   assign                 BVALID = (~resp_empty);
   
   prgen_fifo #(2+ID_BITS, CMD_DEPTH) 
   resp_fifo(
	    .clk(clk),
	    .reset(reset),
	    .push(resp_push),
	    .pop(resp_pop),
	    .din({cmd_resp,
                  WID
		  }
		 ),
	    .dout({BRESP,
                   BID
		   }
		  ),
	    .empty(resp_empty),
	    .full(resp_full)
	    );

   

endmodule

   
