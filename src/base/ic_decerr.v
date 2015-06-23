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

OUTFILE PREFIX_ic_decerr.v

module PREFIX_ic_decerr(PORTS);

   input                          clk;
   input 			  reset;

   input 			  AWIDOK;
   input 			  ARIDOK;
   port 			  GROUP_IC_AXI;

   
   parameter 			  RESP_SLVERR = 2'b10;
   parameter 			  RESP_DECERR = 2'b11;
   
   
   reg 				  AWREADY;
   reg [ID_BITS-1:0] 		  BID;
   reg [1:0] 			  BRESP;
   reg 				  BVALID;
   reg 				  ARREADY;
   reg [ID_BITS-1:0] 		  RID;
   reg [1:0] 			  RRESP;
   reg 				  RVALID;
   reg [4-1:0]                    rvalid_cnt;
   
IFDEF TRUE (USER_BITS>0)
   assign 			  BUSER = 'd0;
   assign 			  RUSER = 'd0;
ENDIF TRUE (USER_BITS>0)
   
   assign 			  RDATA = {DATA_BITS{1'b0}};


   //WRITE
   assign 			  WREADY = 1'b1;
   
   always @(posedge clk or posedge reset)
     if (reset)
       begin
	  AWREADY <= #FFD 1'b1;
	  BID     <= #FFD {ID_BITS{1'b0}};
	  BRESP   <= #FFD 2'b00;
       end
     else if (BVALID & BREADY)
       begin
	  AWREADY <= #FFD 1'b1;
       end
     else if (AWVALID & AWREADY)
       begin
	  AWREADY <= #FFD 1'b0;
	  BID     <= #FFD AWID;
	  BRESP   <= #FFD AWIDOK ? RESP_DECERR : RESP_SLVERR;
       end
   
   always @(posedge clk or posedge reset)
     if (reset)
       BVALID <= #FFD 1'b0;
     else if (WVALID & WREADY & WLAST)
       BVALID <= #FFD 1'b1;
     else if (BVALID & BREADY)
       BVALID <= #FFD 1'b0;

   
   //READ   
   always @(posedge clk or posedge reset)
     if (reset)
       begin
	  ARREADY <= #FFD 1'b1;
	  RID     <= #FFD {ID_BITS{1'b0}};
	  RRESP   <= #FFD 2'b00;
       end
     else if (RVALID & RREADY & RLAST)
       begin
	  ARREADY <= #FFD 1'b1;
       end
     else if (ARVALID & ARREADY)
       begin
	  ARREADY <= #FFD 1'b0;
	  RID     <= #FFD ARID;
	  RRESP   <= #FFD ARIDOK ? RESP_DECERR : RESP_SLVERR;
       end


   always @(posedge clk or posedge reset)
     if (reset)
       rvalid_cnt <= #FFD {4{1'b0}};
     else if (RVALID & RREADY & RLAST)
       rvalid_cnt <= #FFD {4{1'b0}};
     else if (RVALID & RREADY)
       rvalid_cnt <= #FFD rvalid_cnt - 1'b1;
     else if (ARVALID & ARREADY)
       rvalid_cnt <= #FFD ARLEN;

   
   always @(posedge clk or posedge reset)
     if (reset)
       RVALID <= #FFD 1'b0;
     else if (RVALID & RREADY & RLAST)
       RVALID <= #FFD 1'b0;
     else if (ARVALID & ARREADY)
       RVALID <= #FFD 1'b1;
   
   assign RLAST = (rvalid_cnt == 'd0) & RVALID;
     
   
   
   
   
   
endmodule

   
