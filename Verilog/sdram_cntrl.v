/*********************************************************
 MODULE:		Sub Level Controller, SDRAM control signals

 FILE NAME:	sdram_cntrl.v
 VERSION:	1.0
 DATE:		April 28th, 2002
 AUTHOR:		Hossein Amidi
 COMPANY:	
 CODE TYPE:	Register Transfer Level

 DESCRIPTION:	This module is the sub level RTL code of SDRAM Controller ASIC verilog
 code. It is the SDRAM control signals block.


 Hossein Amidi
 (C) April 2002

*********************************************************/

// DEFINES
`timescale 1ns / 10ps

module sdram_cntrl(// Input
							reset,
							clk0,
							wsadd,
							wba,
							wcs,
							wcke,
							wras,
							wcas,
							wwe,
							sdram_in,
							// Output
							add,
							ba,
							cs,
							cke,
							ras,
							cas,
							we,
							dataout
							);

// Parameter
`include        "parameter.v"

// Input
input reset;
input clk0;
input [add_size - 1 : 0]wsadd;
input [ba_size - 1 : 0]wba;
input [cs_size - 1 : 0]wcs;
input wcke;
input wras;
input wcas;
input wwe;
input [data_size - 1 : 0]sdram_in;

// Output
output [add_size - 1 : 0]add;
output [ba_size - 1 : 0]ba;
output [cs_size - 1 : 0]cs;
output cke;
output ras;
output cas;
output we;
output [data_size - 1 : 0]dataout;


// Internal wires and reg
wire reset;
wire clk0;
wire [add_size - 1 : 0]wsadd;
wire [ba_size - 1 : 0]wba;
wire [cs_size - 1 : 0]wcs;
wire wcke;
wire wras;
wire wcas;
wire wwe;
wire [data_size - 1 : 0]sdram_in;

reg [add_size - 1 : 0]add;
reg [ba_size - 1 : 0]ba;
reg [cs_size - 1 : 0]cs;
reg cke;
reg ras;
reg cas;
reg we;
reg [data_size - 1 : 0]dataout;


// Assignment



// SDRAM Memory Control Signals
always @(posedge reset or posedge clk0)
begin
	if(reset == 1'b1)
	begin
		add <= 12'h0;
		ba <= 2'b00;
		cs <= 2'b00;
		cke <= 1'b0;
		ras <= 1'b0;
		cas <= 1'b0;
		we <= 1'b0;
		dataout <= 32'h0000_0000;
	end
	else
	begin
		add <= wsadd;
		ba <= wba;
		cs <= wcs;
		cke <= wcke;
		ras <= wras;
		cas <= wcas;
		we <= wwe;
		dataout <= sdram_in;
	end
end

endmodule
