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

INCLUDE def_axi2apb.txt
OUTFILE PREFIX_mux.v

ITER SX
module  PREFIX_mux (PORTS);


   input 		      clk;
   input                      reset;
   
   input [ADDR_BITS-1:0]      cmd_addr;
   
   input                      psel;
   output [31:0]              prdata;
   output                     pready;
   output                     pslverr;
   
   output                     pselSX;
   
   input                      preadySX;
   
   input                      pslverrSX;

   input [31:0]               prdataSX;
   

   
   parameter                  ADDR_MSB = EXPR(ADDR_BITS-1);
   parameter                  ADDR_LSB = EXPR(ADDR_BITS-DEC_BITS);
   
   reg                        pready;
   reg                        pslverr_pre;
   reg                        pslverr;
   reg [31:0]                 prdata_pre;
   reg [31:0]                 prdata;
   
   reg [SLV_BITS-1:0]         slave_num;
   
   always @(*)
     begin
	casex (cmd_addr[ADDR_MSB:ADDR_LSB])
	  DEC_BITSDEC_ADDRSX : slave_num = SLV_BITS'dSX;
	  
	  default : slave_num = SLV_BITS'dSLAVE_NUM; //decode error
	endcase
     end
   
   assign                     pselSX = psel & (slave_num == SLV_BITS'dSX);
			  
   always @(*)
     begin
	   case (slave_num)
	     SLV_BITS'dSX: pready = preadySX;
		 default : pready = 1'b1; //decode error
           endcase
	 end
   
   always @(*)
     begin
	   case (slave_num)
	     SLV_BITS'dSX: pslverr_pre = pslverrSX;
		 default : pslverr_pre = 1'b1; //decode error
           endcase
	 end
   
   always @(*)
     begin
	   case (slave_num)
	     SLV_BITS'dSX: prdata_pre = prdataSX;
		 default : prdata_pre = {32{1'b0}};
           endcase
	 end
   
   
   always @(posedge clk or posedge reset)
     if (reset)
	   begin
         prdata  <= #FFD {32{1'b0}};
         pslverr <= #FFD 1'b0;
	   end
	 else if (psel & pready)
	   begin
         prdata  <= #FFD prdata_pre;
         pslverr <= #FFD pslverr_pre;
	   end
	 else if (~psel)
	   begin
         prdata  <= #FFD {32{1'b0}};
         pslverr <= #FFD 1'b0;
	   end
   
endmodule

   
