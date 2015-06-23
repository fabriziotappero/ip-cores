/*********************************************************
 MODULE:		Sub Level Command Interface Decoder

 FILE NAME:	cmd_decoder.v
 VERSION:	1.0
 DATE:		April 28th, 2002
 AUTHOR:		Hossein Amidi
 COMPANY:	
 CODE TYPE:	Register Transfer Level

 DESCRIPTION:	This module is the sub level RTL code of SDRAM Controller ASIC verilog
 code. It will Decode the incoming uProcessor command for internal State Machines.


 Hossein Amidi
 (C) April 2002

*********************************************************/

// DEFINES
`timescale 1ns / 10ps


module cmd_decoder(// Input
							reset,
							clk0,
							paddr,
							cmd,
							cmdack,
							// Output
							nop,
							reada,
							writea,
							refresh,
							preacharge,
							load_mod,
							load_time,
							load_rfcnt,
							caddr
							);

// Parameter
`include        "parameter.v"

// Input
input reset;
input clk0;
input [padd_size - 1 : 0]paddr;
input [cmd_size  - 1 : 0]cmd;
input cmdack; 

// Output
output nop;
output reada;
output writea;
output refresh;
output preacharge;
output load_mod;
output load_time;
output load_rfcnt;
output [padd_size - 1 : 0]caddr;


// Internal wire and reg signals
reg nop;
reg reada;
reg writea;
reg refresh;
reg preacharge;
reg load_mod;
reg load_time;
reg load_rfcnt;
reg [padd_size - 1 : 0]caddr;


// Assignment



//Command Decoder and Address Register
always @(posedge reset or posedge clk0)
begin
	if(reset == 1'b1)
	begin
		nop        	<= 1'b0;
		reada      	<= 1'b0;
		writea		<= 1'b0;
		refresh		<= 1'b0;
		preacharge	<= 1'b0;
		load_mod		<= 1'b0;
		load_time   <= 1'b0;
		load_rfcnt  <= 1'b0;
		caddr 		<= 24'h00_0000;
	end
	else
	begin
		// Register the Address Buss to match the timing
		caddr <= paddr;

		if(cmd == 3'b000)
			nop <= 1'b1;
		else
			nop <= 1'b0;

		if(cmd == 3'b001)
			reada <= 1'b1;
		else
			reada <= 1'b0;

		if(cmd == 3'b010)
			writea <= 1'b1;
		else
			writea <= 1'b0;

		if(cmd == 3'b011)
			refresh <= 1'b1;
		else
			refresh <= 1'b0;

		if(cmd == 3'b100)
			preacharge <= 1'b1;
		else
			preacharge <= 1'b0;

		if(cmd == 3'b101)
			load_mod <= 1'b1;
		else
			load_mod <= 1'b0;

		if((cmd == 3'b110) & (load_time == 1'b0) & (cmdack == 1'b0))
			load_time <= 1'b1;
		else
			load_time <= 1'b0;

		if((cmd == 3'b111) & (load_rfcnt == 1'b0) & (cmdack == 1'b0))
			load_rfcnt <= 1'b1;
		else
			load_rfcnt <= 1'b0;
	end
end

/*
		casex({cmdack,load_rfcnt,load_time,cmd})
	
			6'bx_x_x_000: nop 			<= 1'b1;
			6'bx_x_x_001: reada 			<= 1'b1;
			6'bx_x_x_010: writea			<= 1'b1;
			6'bx_x_x_011: refresh 		<= 1'b1;
			6'bx_x_x_100: preacharge	<= 1'b1;
			6'bx_x_x_101: load_mod		<= 1'b1;
			6'b0_x_0_110: load_time		<= 1'b1;
			6'b0_0_x_111: load_rfcnt	<= 1'b1;
			default:
			begin
				nop 			<= 1'b0;
				reada 		<= 1'b0;
				writea 		<= 1'b0;
				refresh 		<= 1'b0;
				preacharge 	<= 1'b0;
				load_mod 	<= 1'b0;
				load_time 	<= 1'b0;
				load_rfcnt 	<= 1'b0;
			end
		endcase
*/

endmodule
