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
OUTFILE PREFIX.v

CHECK CONST(#FFD)
CHECK CONST(PREFIX)
CHECK CONST(ADDR_BITS)
CHECK CONST(DATA_BITS)
CHECK CONST(ID_BITS)
CHECK CONST(CMD_DEPTH)
  
module  PREFIX (PORTS);

   input              clk;
   input              reset;

   port               GROUP_AXI;

   revport            GROUP_AHB;

   
   //outputs of cmd
   wire                   cmd_empty;
   wire                   cmd_read;
   wire [ID_BITS-1:0]     cmd_id;
   wire [ADDR_BITS-1:0]   cmd_addr;
   wire [3:0]             cmd_len;
   wire [1:0]             cmd_size;
   wire                   cmd_err;
   
   //outputs of ctrl
   wire                   ahb_finish;
   wire                   data_last;

   //outputs of wr fifo
   wire                   wdata_phase;
   wire                   wdata_ready;
   
   //outputs of rd fifo
   wire                   rdata_phase;
   wire                   rdata_ready;
 

   
   CREATE axi2ahb_cmd.v
     PREFIX_cmd PREFIX_cmd(
					   .clk(clk),
					   .reset(reset),
					   .AWGROUP_AXI_A(AWGROUP_AXI_A),
					   .ARGROUP_AXI_A(ARGROUP_AXI_A),
					   .GROUP_AHB(GROUP_AHB),
					   .ahb_finish(ahb_finish),
					   .cmd_empty(cmd_empty),
					   .cmd_read(cmd_read),
					   .cmd_id(cmd_id),
					   .cmd_addr(cmd_addr),
					   .cmd_len(cmd_len),
					   .cmd_size(cmd_size),
                                           .cmd_err(cmd_err)
                                           );

   

   CREATE axi2ahb_ctrl.v
     PREFIX_ctrl PREFIX_ctrl(
					     .clk(clk),
					     .reset(reset),
					     .GROUP_AHB(GROUP_AHB),
                                             .ahb_finish(ahb_finish),
                                             .rdata_phase(rdata_phase),
                                             .wdata_phase(wdata_phase),
                                             .data_last(data_last),
                                             .rdata_ready(rdata_ready),
                                             .wdata_ready(wdata_ready),
                                             .cmd_empty(cmd_empty),
                                             .cmd_read(cmd_read),
                                             .cmd_addr(cmd_addr),
                                             .cmd_len(cmd_len),
                                             .cmd_size(cmd_size)
                                             );

   
   CREATE axi2ahb_wr_fifo.v
     PREFIX_wr_fifo 
       PREFIX_wr_fifo(
			      .clk(clk),
			      .reset(reset),
			      .WGROUP_AXI_W(WGROUP_AXI_W),
			      .BGROUP_AXI_B(BGROUP_AXI_B),
                              .HWDATA(HWDATA),
                              .HREADY(HREADY),
                              .HTRANS(HTRANS),
                              .HRESP(HRESP),
                              .cmd_err(cmd_err),
                              .wdata_phase(wdata_phase),
                              .wdata_ready(wdata_ready),
                              .data_last(data_last)
                              );

   
   CREATE axi2ahb_rd_fifo.v
     PREFIX_rd_fifo 
       PREFIX_rd_fifo(
			      .clk(clk),
			      .reset(reset),
			      .RGROUP_AXI_R(RGROUP_AXI_R),
                              .HRDATA(HRDATA),
                              .HREADY(HREADY),
                              .HTRANS(HTRANS),
                              .HRESP(HRESP),
			      .cmd_id(cmd_id),
                              .cmd_err(cmd_err),
                              .rdata_phase(rdata_phase),
                              .rdata_ready(rdata_ready),
                              .data_last(data_last)
                              );
   

endmodule


