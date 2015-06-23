//////////////////////////////////////////////////////////////////////
////                                                              ////
//// WISHBONE SD Card Controller IP Core                          ////
////                                                              ////
//// sdc_controller_top.v                                         ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
//// http://opencores.org/project,sd_card_controller              ////
////                                                              ////
//// Description                                                  ////
//// Top level entity of synthesis test project.                  ////
////                                                              ////
//// Author(s):                                                   ////
////     - Marek Czerski, ma.czerski@gmail.com                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2013 Authors                                   ////
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
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
////////////////////////////////////////////////////////////////////// 

module sdc_controller_top(
           // WISHBONE common
           wb_clk_i, wb_rst_i, wb_dat_i, wb_dat_o_reg,
           // WISHBONE slave
           wb_adr_i, wb_sel_i, wb_we_i, wb_cyc_i, wb_stb_i, wb_ack_o_reg,
           // WISHBONE master
           m_wb_adr_o_reg, m_wb_sel_o_reg, m_wb_we_o_reg,
           m_wb_dat_o_reg, m_wb_dat_i, m_wb_cyc_o_reg,
           m_wb_stb_o_reg, m_wb_ack_i,
           m_wb_cti_o_reg, m_wb_bte_o_reg,
           //SD BUS
           sd_cmd_dat_i, sd_cmd_out_o_reg, sd_cmd_oe_o_reg, //card_detect,
           sd_dat_dat_i, sd_dat_out_o_reg, sd_dat_oe_o_reg, sd_clk_o_pad,
           int_cmd_reg, int_data_reg
       );

input wb_clk_i;
input wb_rst_i;
input [31:0] wb_dat_i;
output reg [31:0] wb_dat_o_reg;
input [7:0] wb_adr_i;
input [3:0] wb_sel_i;
input wb_we_i;
input wb_cyc_i;
input wb_stb_i;
output reg wb_ack_o_reg;
output reg [31:0] m_wb_adr_o_reg;
output reg [3:0] m_wb_sel_o_reg;
output reg m_wb_we_o_reg;
input [31:0] m_wb_dat_i;
output reg [31:0] m_wb_dat_o_reg;
output reg m_wb_cyc_o_reg;
output reg m_wb_stb_o_reg;
input m_wb_ack_i;
output reg [2:0] m_wb_cti_o_reg;
output reg [1:0] m_wb_bte_o_reg;
input [3:0] sd_dat_dat_i;
output reg [3:0] sd_dat_out_o_reg;
output reg sd_dat_oe_o_reg;
input sd_cmd_dat_i;
output reg sd_cmd_out_o_reg;
output reg sd_cmd_oe_o_reg;
output sd_clk_o_pad;
output reg int_cmd_reg;
output reg int_data_reg;

reg [31:0] wb_dat_i_reg;
wire [31:0] wb_dat_o;
reg [7:0] wb_adr_i_reg;
reg [3:0] wb_sel_i_reg;
reg wb_we_i_reg;
reg wb_cyc_i_reg;
reg wb_stb_i_reg;
wire wb_ack_o;
wire [31:0] m_wb_adr_o;
wire [3:0] m_wb_sel_o;
wire m_wb_we_o;
reg [31:0] m_wb_dat_i_reg;
wire [31:0] m_wb_dat_o;
wire m_wb_cyc_o;
wire m_wb_stb_o;
reg m_wb_ack_i_reg;
wire [2:0] m_wb_cti_o;
wire [1:0] m_wb_bte_o;
reg [3:0] sd_dat_dat_i_reg;
wire [3:0] sd_dat_out_o;
wire sd_dat_oe_o;
reg sd_cmd_dat_i_reg;
wire sd_cmd_out_o;
wire sd_cmd_oe_o;
wire int_cmd;
wire int_data;

always @(posedge wb_clk_i) begin
    wb_dat_i_reg <= wb_dat_i;
    wb_dat_o_reg <= wb_dat_o;
    wb_adr_i_reg <= wb_adr_i;
    wb_sel_i_reg <= wb_sel_i;
    wb_we_i_reg <= wb_we_i;
    wb_cyc_i_reg <= wb_cyc_i;
    wb_stb_i_reg <= wb_stb_i;
    wb_ack_o_reg <= wb_ack_o;
    m_wb_adr_o_reg <= m_wb_adr_o;
    m_wb_sel_o_reg <= m_wb_sel_o;
    m_wb_we_o_reg <= m_wb_we_o;
    m_wb_dat_i_reg <= m_wb_dat_i;
    m_wb_dat_o_reg <= m_wb_dat_o;
    m_wb_cyc_o_reg <= m_wb_cyc_o;
    m_wb_stb_o_reg <= m_wb_stb_o;
    m_wb_ack_i_reg <= m_wb_ack_i;
    m_wb_cti_o_reg <= m_wb_cti_o;
    m_wb_bte_o_reg <= m_wb_bte_o;
    sd_dat_dat_i_reg <= sd_dat_dat_i;
    sd_dat_out_o_reg <= sd_dat_out_o;
    sd_dat_oe_o_reg <= sd_dat_oe_o;
    sd_cmd_dat_i_reg <= sd_cmd_dat_i;
    sd_cmd_out_o_reg <= sd_cmd_out_o;
    sd_cmd_oe_o_reg <= sd_cmd_oe_o;
    int_cmd_reg <= int_cmd;
    int_data_reg <= int_data;
end

sdc_controller sdc_controller0 (
           wb_clk_i, 
           wb_rst_i, 
           wb_dat_i_reg, 
           wb_dat_o,
           wb_adr_i_reg, 
           wb_sel_i_reg, 
           wb_we_i_reg, 
           wb_cyc_i_reg, 
           wb_stb_i_reg, 
           wb_ack_o,
           m_wb_dat_o,
           m_wb_dat_i_reg,
           m_wb_adr_o, 
           m_wb_sel_o, 
           m_wb_we_o,
           m_wb_cyc_o,
           m_wb_stb_o, 
           m_wb_ack_i_reg,
           m_wb_cti_o, 
           m_wb_bte_o,
           sd_cmd_dat_i_reg, 
           sd_cmd_out_o, 
           sd_cmd_oe_o,
           sd_dat_dat_i_reg, 
           sd_dat_out_o, 
           sd_dat_oe_o, 
           sd_clk_o_pad,
           wb_clk_i,
           int_cmd, 
           int_data
    );
    
endmodule