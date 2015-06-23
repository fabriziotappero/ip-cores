/*********************************************************
 MODULE:		Sub Level Command Acknowledge

 FILE NAME:	cmd_ack.v
 VERSION:	1.0
 DATE:		April 28th, 2002
 AUTHOR:		Hossein Amidi
 COMPANY:	
 CODE TYPE:	Register Transfer Level

 DESCRIPTION:	This module is the sub level RTL code of SDRAM Controller ASIC verilog
 code. It will generate the command acknowledge signal.


 Hossein Amidi
 (C) April 2002

*********************************************************/

// DEFINES
`timescale 1ns / 10ps

module cmd_ack(// Input
					reset,
					clk0,
					cmack,
					load_time,
					load_rfcnt,
					// Output
					cmdack
					);


// Parameter
`include        "parameter.v"

// Input
input reset;
input clk0;
input cmack;
input load_time;
input load_rfcnt;

// Output
output cmdack;

// Internal wire and reg signals
reg cmdack;

// Assignment

// Generating CMDACK Signal
always @(posedge reset or posedge clk0)
begin
	if(reset == 1'b1)
		cmdack <= 1'b0;
	else
	begin
		if(((cmack == 1'b1) | (load_time == 1'b1) | (load_rfcnt == 1'b1)) & (cmdack == 1'b0))
			cmdack <= 1'b1;
		else
			cmdack <= 1'b0;
	end
end

endmodule
