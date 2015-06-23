/*********************************************************
 MODULE:		Sub Level SDRAM Controller Data input register

 FILE NAME:	data_in_reg.v
 VERSION:	1.0
 DATE:		April 28th, 2002
 AUTHOR:		Hossein Amidi
 COMPANY:	
 CODE TYPE:	Register Transfer Level

 DESCRIPTION:	This module is the sub level RTL code of SDRAM Controller ASIC verilog
 code. It is the Controller input Data Port register block.


 Hossein Amidi
 (C) April 2002

*********************************************************/

// DEFINES
`timescale 1ns / 10ps

module data_in_reg(// Input
							reset,
							clk0,
							dm,
							datain,
							// Out
							dqm,
							datain2
							);


// Parameter
`include        "parameter.v"

// Input
input reset;
input clk0;
input [dqm_size - 1 : 0]dm;
input [data_size - 1 : 0]datain;

// Output
output [dqm_size - 1 : 0]dqm;
output [data_size - 1 : 0]datain2;


// Internal wires and reg
reg [data_size - 1 : 0]datain1;
reg [data_size - 1 : 0]datain2;
reg [dqm_size - 1 : 0]dqm;

wire [data_size - 1 : 0]datain;
wire [dqm_size - 1 : 0]dm;



// Assignment

// Register the input data from the host to match the internal timing
// and avoid metastability issues by double registering it.
always @(posedge reset or posedge clk0)
begin
	if(reset == 1'b1)
	begin
		datain1 <= 32'h0;
		datain2 <= 32'h0;
		dqm     <= 4'h0;
	end
	else
	begin
		datain1 <= datain;
		datain2 <= datain1;
		dqm <= dm;
	end
end

endmodule
