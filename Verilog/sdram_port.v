/*********************************************************
 MODULE:		Sub Level Controller, SDRAM Data Port

 FILE NAME:	sdram_port.v
 VERSION:	1.0
 DATE:		April 28th, 2002
 AUTHOR:		Hossein Amidi
 COMPANY:	
 CODE TYPE:	Register Transfer Level

 DESCRIPTION:	This module is the sub level RTL code of SDRAM Controller ASIC verilog
 code. It is the SDRAM Data Port block.


 Hossein Amidi
 (C) April 2002

*********************************************************/

// DEFINES
`timescale 1ns / 10ps

module sdram_port(// Input
						reset,
						clk0_2x,
						oe,
						datain2,
						dq,
						// Output
						sdram_in,
						sdram_out
						);


// Parameter
`include        "parameter.v"

// Input
input reset;
input clk0_2x;
input oe;
input [data_size - 1 : 0]datain2;
input [data_size - 1 : 0]dq;

// Output
output [data_size - 1 : 0]sdram_in;
output [data_size - 1 : 0]sdram_out;

// Internal wires and reg
wire reset;
wire clk0_2x;
wire oe;
wire [data_size - 1 : 0]datain2;
wire [data_size - 1 : 0]dq;

reg [data_size - 1 : 0]sdram_in;
reg [data_size - 1 : 0]sdram_out;


// Assignment


// Register the output tri-state bidirectional Data Signals
always @(posedge reset or negedge clk0_2x)
begin
	if(reset == 1'b1)
   begin
		sdram_in  <= 32'hzzzzzzzz;
		sdram_out <= 32'hzzzzzzzz;
	end
	else
	begin
		if(oe == 1'b1)
		begin
			sdram_out <= datain2;
			sdram_in  <= 32'hzzzzzzzz;
		end
		else
		if(oe == 1'b0)
		begin
			sdram_in  <= dq;
			sdram_out <= 32'hzzzzzzzz;
		end
	end
end

endmodule
