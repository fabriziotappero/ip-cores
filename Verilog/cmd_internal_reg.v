/*********************************************************
 MODULE:		Sub Level Command Interface Internal Register

 FILE NAME:	cmd_internal_reg.v
 VERSION:	1.0
 DATE:		April 28th, 2002
 AUTHOR:		Hossein Amidi
 COMPANY:	
 CODE TYPE:	Register Transfer Level

 DESCRIPTION:	This module is the sub level RTL code of SDRAM Controller ASIC verilog
 code. It will store the timing and refresh commands into internal registers.


 Hossein Amidi
 (C) April 2002

*********************************************************/

// DEFINES
`timescale 1ns / 10ps

module internal_reg(// Input
								reset,
								clk0,
								load_time,
								load_rfcnt,
								caddr,
								// Output
								cas_lat,
								ras_cas,
								ref_dur,
								page_mod,
								bur_len,
								refresh_count
								);


// Parameter
`include        "parameter.v"

// Input
input reset;
input clk0;
input load_time;
input load_rfcnt;
input [padd_size - 1 : 0]caddr; 

// Output
output [cas_size - 1 : 0]cas_lat;
output [rc_size - 1 : 0]ras_cas;
output [ref_dur_size - 1 : 0]ref_dur;
output page_mod;
output [burst_size - 1 : 0]bur_len;
output [15:0]refresh_count; 

// Internal wire and reg signals
reg [cas_size - 1 : 0]cas_lat;
reg [rc_size - 1 : 0]ras_cas;
reg [ref_dur_size - 1 : 0]ref_dur;
reg page_mod;
reg [burst_size - 1 : 0]bur_len;
reg [15:0]refresh_count;


// Assignment


// Loading Reg1 and Reg2
always @(posedge reset or posedge clk0)
begin
	if(reset == 1'b1)
	begin
		cas_lat  		<= 2'b00;
		ras_cas  		<= 2'b00;
		ref_dur  		<= 4'b0000;
		page_mod 		<= 1'b0;
		bur_len        <= 4'b0000;
		refresh_count  <= 16'h0000;		
	end
	else
	begin
		if(load_time == 1'b1)
		begin
			cas_lat  <= caddr[1:0];
			ras_cas  <= caddr[3:2];
			ref_dur  <= caddr[7:4];
			page_mod <= caddr[8];
			bur_len  <= caddr[12:9];
		end

		if(load_rfcnt == 1'b1)
			refresh_count  <= caddr[15:0];

	end
end

endmodule
