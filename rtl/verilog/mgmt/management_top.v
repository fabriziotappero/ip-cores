`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////
//// 																					////
//// MODULE NAME: manage_top mdoule 										////
//// 																					////
//// DESCRIPTION: Implement Management module to config the MAC,  ////
////              read statistics info, and get PHY info via MDIO ////
////																					////
//// This file is part of the 10 Gigabit Ethernet IP core project ////
////  http://www.opencores.org/projects/ethmac10g/						////
////																					////
//// AUTHOR(S):																	////
//// Zheng Cao			                                             ////
////							                                    		////
//////////////////////////////////////////////////////////////////////
////																					////
//// Copyright (c) 2005 AUTHORS.  All rights reserved.			   ////
////																					////
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
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml   						////
////																					////
//////////////////////////////////////////////////////////////////////
//
// CVS REVISION HISTORY:
//
// $Log: not supported by cvs2svn $
// Revision 1.2  2006/06/15 05:09:24  fisher5090
// bad coding style, but works, will be modified later
//
// Revision 1.1  2005/12/25 16:43:10  Zheng Cao
// 
// 
//
//////////////////////////////////////////////////////////////////////
module management_top(mgmt_clk, rxclk, txclk, mgmt_opcode, mgmt_addr, mgmt_wr_data, mgmt_rd_data,
                      mgmt_miim_sel, mgmt_req, mgmt_miim_rdy, rxStatRegPlus, txStatRegPlus,
                      cfgRxRegData, cfgTxRegData, mdc, mdio, reset);
input mgmt_clk; //management clock
input rxclk; //receive clock
input txclk; //transmit clock
input[1:0] mgmt_opcode; //management opcode(read/write/mdio)
input[9:0] mgmt_addr; //management address, including addresses of configuration, statistics and MDIO registers
input[31:0] mgmt_wr_data; //Data to be writen to Configuration/MDIO registers
output[31:0] mgmt_rd_data; //Data read from Configuration/Statistics/MDIO registers
input mgmt_miim_sel; //select internal register or MDIO registers
input mgmt_req; //Valid when operate statistics/MDIO registers, one clock valid____|-|____
output mgmt_miim_rdy; //Indicate the Management Module is in IDLE Status
input[18:0] rxStatRegPlus; //From Receive Module, one bit is related to one receive statistics register
input[14:0] txStatRegPlus; //From Transmit Module, one bit is related to one transmit statistics register
output[52:0] cfgRxRegData; //To Receive Module, config receive module
output[9:0] cfgTxRegData; //To Transmit Module, config transmit module
output mdc;
inout mdio;
input reset;

wire[1:0] mdio_opcode;
wire mdio_out_valid;
wire mdio_in_valid;
wire[25:0] mdio_data_out;
wire[15:0] mdio_data_in;
wire[31:0] mgmt_config;

IOBUF mdio_gen(.I(mdio_o), .O(mdio_i), .T(mdio_t), .IO(mdio));

/////////////////////////////////////////////////////
// Read&Write Logic for Config&Statistics Registers
/////////////////////////////////////////////////////
manage_registers mgmt_interface(.mgmt_clk(mgmt_clk), .rxclk(rxclk), .txclk(txclk), .reset(reset), .mgmt_opcode(mgmt_opcode), .mgmt_addr(mgmt_addr),
.mgmt_wr_data(mgmt_wr_data), .mgmt_rd_data(mgmt_rd_data), .mgmt_miim_sel(mgmt_miim_sel), .mgmt_req(mgmt_req), 
.mgmt_miim_rdy(mgmt_miim_rdy), .rxStatRegPlus(rxStatRegPlus), .txStatRegPlus(txStatRegPlus), .cfgRxRegData(cfgRxRegData),
.cfgTxRegData(cfgTxRegData), .mdio_opcode(mdio_opcode), .mdio_data_out(mdio_data_out), .mdio_data_in(mdio_data_in), 
.mdio_in_valid(mdio_in_valid), .mdio_out_valid(mdio_out_valid), .mgmt_config(mgmt_config));

//////////////////////////////////////////
// Generate MDIO signals
//////////////////////////////////////////
mdio mdio_inst(.mgmt_clk(mgmt_clk), .reset(reset), .mdc(mdc), .mdio_t(mdio_t), .mdio_i(mdio_i), .mdio_o(mdio_o), .mdio_opcode(mdio_opcode), 
.mdio_in_valid(mdio_in_valid), .mdio_data_in(mdio_data_in), .mdio_out_valid(mdio_out_valid), .mdio_data_out(mdio_data_out), .mgmt_config(mgmt_config));



endmodule
