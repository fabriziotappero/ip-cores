// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
//
// Revision Control Information
//
// $RCSfile: $
// $Source: $
//
// $Revision: #1 $
// $Date: 2012/06/21 $
// Check in by : $Author: swbranch $
// Author      : SKNg/TTChong
//
// Project     : Triple Speed Ethernet - 10/100/1000 MAC
//
// Description : (Simulation only)
//
// MDIO Slave model
// Instantiates mdio_slave (mdio_slave.v) and mdio_reg_sim (mdio_reg.v)
// 
// ALTERA Confidential and Proprietary
// Copyright 2006 (c) Altera Corporation
// All rights reserved
//
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------

`timescale 1 ns / 10 ps
//`include "common_header.verilog" 

module top_mdio_slave (reset,
   mdc,
   mdio,
   dev_addr,
   conf_done);
input   reset; 
input   mdc; 
inout   mdio; 
input   [4:0] dev_addr; 
output   conf_done; 
wire    VHDL2V_mdio; 
wire    mdio; 
wire    conf_done; 
wire    [4:0] reg_addr; //  Address register
wire    reg_read; //  Read register         
wire    reg_write; //  Write register         
wire    [15:0] reg_dout; //  Data Bus OUT
wire    [15:0] reg_din; //  Data Bus IN 

mdio_slave mdio_c (.reset(reset),
          .mdc(mdc),
          .mdio(mdio),
          .dev_addr(dev_addr),
          .reg_addr(reg_addr),
          .reg_read(reg_read),
          .reg_write(reg_write),
          .reg_dout(reg_din),
          .reg_din(reg_dout));
mdio_reg_sim reg_c (.reset(reset),
          .clk(mdc),
          .reg_addr(reg_addr),
          .reg_write(reg_write),
          .reg_read(reg_read),
          .reg_dout(reg_dout),
          .reg_din(reg_din),
          .conf_done(conf_done));
assign mdio = VHDL2V_mdio; 

endmodule // module top_mdio_slave

