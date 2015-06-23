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
  OUTFILE PREFIX.v

    ITER SX
      module  PREFIX (PORTS);

   input              clk;
   input              reset;

   port               GROUP_APB_AXI;
   
   //apb slaves
IFDEF TRUE(SLAVE_NUM==1)
   port               GROUP_APB3;
ELSE TRUE(SLAVE_NUM==1)
   output             penable;
   output             pwrite;
   output [ADDR_BITS-1:0] paddr;
   output [31:0]          pwdata;
   output                 pselSX;
   input [31:0]           prdataSX;
   input                  preadySX;
   input                  pslverrSX;
ENDIF TRUE(SLAVE_NUM==1)



   wire                   GROUP_APB3;
   
   //outputs of cmd
   wire                   cmd_empty;
   wire                   cmd_read;
   wire [ID_BITS-1:0]     cmd_id;
   wire [ADDR_BITS-1:0]   cmd_addr;
   wire                   cmd_err;
   
   //outputs of rd / wr
   wire                   finish_wr;
   wire                   finish_rd;
   
   
   assign                 paddr  = cmd_addr;
   assign                 pwdata = WDATA;

   
   CREATE axi2apb_cmd.v
     PREFIX_cmd PREFIX_cmd(
					   .clk(clk),
					   .reset(reset),
					   .AWGROUP_APB_AXI_A(AWGROUP_APB_AXI_A),
					   .ARGROUP_APB_AXI_A(ARGROUP_APB_AXI_A),
					   .finish_wr(finish_wr),
					   .finish_rd(finish_rd),
					   .cmd_empty(cmd_empty),
					   .cmd_read(cmd_read),
					   .cmd_id(cmd_id),
					   .cmd_addr(cmd_addr),
					   .cmd_err(cmd_err)
                                           );

   
   CREATE axi2apb_rd.v
     PREFIX_rd PREFIX_rd(
					 .clk(clk),
					 .reset(reset),
					 .GROUP_APB3(GROUP_APB3),
					 .cmd_err(cmd_err),
					 .cmd_id(cmd_id),
					 .finish_rd(finish_rd),
					 .RGROUP_APB_AXI_R(RGROUP_APB_AXI_R),
                                         STOMP ,
					 );
   
   CREATE axi2apb_wr.v
     PREFIX_wr PREFIX_wr(
					 .clk(clk),
					 .reset(reset),
					 .GROUP_APB3(GROUP_APB3),
					 .cmd_err(cmd_err),
					 .cmd_id(cmd_id),
					 .finish_wr(finish_wr),
					 .WGROUP_APB_AXI_W(WGROUP_APB_AXI_W),
					 .BGROUP_APB_AXI_B(BGROUP_APB_AXI_B),
                                         STOMP ,
					 );
      

   
   CREATE axi2apb_ctrl.v						
     PREFIX_ctrl PREFIX_ctrl(
					     .clk(clk),
					     .reset(reset),
					     .finish_wr(finish_wr),			
					     .finish_rd(finish_rd),
					     .cmd_empty(cmd_empty),
					     .cmd_read(cmd_read),
					     .WVALID(WVALID),
					     .psel(psel),
					     .penable(penable),
					     .pwrite(pwrite),
					     .pready(pready)
					     );

   
IFDEF TRUE(SLAVE_NUM>1)
   CREATE axi2apb_mux.v
     PREFIX_mux PREFIX_mux(
					   .clk(clk),
					   .reset(reset),
					   .cmd_addr(cmd_addr),
					   .psel(psel),
					   .prdata(prdata),
					   .pready(pready),
					   .pslverr(pslverr),
					   .pselSX(pselSX),
					   .preadySX(preadySX),
					   .pslverrSX(pslverrSX),
					   .prdataSX(prdataSX),
					   STOMP ,
					   );
ENDIF TRUE(SLAVE_NUM>1)

endmodule


