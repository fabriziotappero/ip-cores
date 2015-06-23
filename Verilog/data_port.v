/*********************************************************
 MODULE:		Sub Level SDRAM Controller Data Port Block

 FILE NAME:	data_port.v
 VERSION:	1.0
 DATE:		April 8nd, 2002
 AUTHOR:		Hossein Amidi
 COMPANY:	
 CODE TYPE:	Register Transfer Level

 DESCRIPTION:	This module is the sub level RTL code of SDRAM Controller ASIC verilog
 code. It is the Data Port block.

  It will instantiate the following blocks in the ASIC:

 1)   Data input register
 2)	SDRAM control signals
 3)	SDRAM Data port
 4)	SDRAM Data port Multiplexor

 Hossein Amidi
 (C) April 2002

*********************************************************/

// DEFINES
`timescale 1ns / 10ps

module data_port(// Input
						reset,
						clk0,
						clk0_2x,
						dm,
						oe,
						datain,
						wsadd,
						wba,
						wcs,
						wcke,
						wras,
						wcas,
						wwe,
						// Out
						dqm,
						dataout,
						add,
						ba,
						cs,
						cke,
						ras,
						cas,
						we,
						// Inout
						dq
						);


// Parameter
`include        "parameter.v"

// Input
input reset;
input clk0;
input clk0_2x;
input [dqm_size - 1 : 0]dm;
input oe;
input [data_size - 1 : 0]datain;
input [add_size - 1 : 0]wsadd;
input [ba_size - 1 : 0]wba;
input [cs_size - 1 : 0]wcs;
input wcke;
input wras;
input wcas;
input wwe;

// Output
output [dqm_size - 1 : 0]dqm;
output [data_size - 1 : 0]dataout;
output [add_size - 1 : 0]add;
output [ba_size - 1 : 0]ba;
output [cs_size - 1 : 0]cs;
output cke;
output ras;
output cas;
output we;

// Inout
inout [data_size - 1 : 0]dq;

// Internal wires and reg
wire reset;
wire clk0;
wire [dqm_size - 1 : 0]dm;
wire [data_size - 1 : 0]datain;
wire [dqm_size - 1 : 0]dqm;
wire [data_size - 1 : 0]datain2;

wire [add_size - 1 : 0]wsadd;
wire [ba_size - 1 : 0]wba;
wire [cs_size - 1 : 0]wcs;
wire wcke;
wire wras;
wire wcas;
wire wwe;
wire [data_size - 1 : 0]wsdram_in;

wire [add_size - 1 : 0]add;
wire [ba_size - 1 : 0]ba;
wire [cs_size - 1 : 0]cs;
wire cke;
wire ras;
wire cas;
wire we;
wire [data_size - 1 : 0]dataout;

wire clk0_2x;
wire oe;
wire [data_size - 1 : 0]dq;
wire [data_size - 1 : 0]sdram_in;
wire [data_size - 1 : 0]sdram_out;


// Assignment


/***************************** Sub Level Instantiation ********************************/


data_in_reg data_in_reg0(// Input
								.reset(reset),
								.clk0(clk0),
								.dm(dm),
								.datain(datain),
								// Output
								.dqm(dqm),
								.datain2(datain2)
								);

sdram_cntrl sdram_cntrl0(// Input
								.reset(reset),
								.clk0(clk0),
								.wsadd(wsadd),
								.wba(wba),
								.wcs(wcs),
								.wcke(wcke),
								.wras(wras),
								.wcas(wcas),
								.wwe(wwe),
								.sdram_in(sdram_in),
								// Output
								.add(add),
								.ba(ba),
								.cs(cs),
								.cke(cke),
								.ras(ras),
								.cas(cas),
								.we(we),
								.dataout(dataout)
								);


sdram_port sdram_port0(	// Input
								.reset(reset),
								.clk0_2x(clk0_2x),
								.oe(oe),
								.datain2(datain2),
								.dq(dq),
								// Output
								.sdram_in(sdram_in),
								.sdram_out(sdram_out)
								);

sdram_mux sdram_mux0(// Input
							.sdram_out(sdram_out),
							.oe(oe),
							// Output
							.dq(dq)
							);


endmodule
