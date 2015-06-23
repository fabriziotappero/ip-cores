//******************************************************************************************************
// Copyright (c) 2007 TooMuch Semiconductor Solutions Pvt Ltd.


//File name             :       wb_ahb_interface.sv
//Designer		:	Ravi S Gupta
//Date                  :       4 Sept, 2007
//Description   	:       Interface for WISHBONE_AHB Bridge
//Revision              :       1.0

//******************************************************************************************************

`timescale 1 ns/ 1 ps
import global::*;
interface wb_ahb_if;
//master to bridge
	logic clk_i;
	logic rst_i;
	logic [DWIDTH-1:0]data_i;
	logic [AWIDTH-1:0]addr_i;
	logic ack_o;
	logic cyc_i;
	logic stb_i;
	logic we_i;
	logic [DWIDTH-1:0]data_o;
	logic [3:0] sel_i;
//bridge to slave
	logic hclk;
	logic hresetn;
	logic hwrite;
	logic [AWIDTH-1:0]haddr;
	logic [DWIDTH-1:0]hwdata;
	logic [2:0]hburst;
	logic [2:0]hsize;
	logic [1:0]htrans;
	logic [1:0]hresp;
	logic hready;
	logic [DWIDTH-1:0]hrdata;
modport master_wb ( output clk_i,
		output rst_i,
		output data_i,
		output addr_i,
		output cyc_i,
		output stb_i,
		output we_i,
		output sel_i,
		input data_o,
		input ack_o
		);
modport slave_wb(input clk_i,
		input rst_i,
		input data_i,
		input addr_i,
		input cyc_i,
		input stb_i,
		input we_i,
		input sel_i,
		output data_o,
		output ack_o
		);
modport master_ba(input hclk,
		input hresetn,
		input hwrite,
		input haddr,
		input hwdata,
		input hburst,
		input hsize,
		input htrans,
		output hready,
		output hresp,
		output hrdata
		);
modport slave_ba(input hready,
		input hresp,
		input hrdata,
		output hclk,
		output hresetn,
		output hwrite,
		output haddr,
		output hwdata,
		output hburst,
		output hsize,
		output htrans
		);
modport monitor( 
// signals from master to bridge 
		input clk_i,
		input rst_i,
		input data_i,
		input addr_i,
		input ack_o,
		input cyc_i,
		input stb_i,
		input we_i,
		input data_o,
		input sel_i,
// signals from bridge to slave 
		input hclk,
		input hresetn,
		input hwrite,
		input haddr,
		input hwdata,
		input hburst,
		input hsize,
		input htrans,
		input hresp,
		input hready,
		input hrdata
		);
endinterface
