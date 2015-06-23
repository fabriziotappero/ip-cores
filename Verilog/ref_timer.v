/*********************************************************
 MODULE:		Sub Level Refresh Timer

 FILE NAME:	ref_timer.v
 VERSION:	1.0
 DATE:		April 28th, 2002
 AUTHOR:		Hossein Amidi
 COMPANY:	
 CODE TYPE:	Register Transfer Level

 DESCRIPTION:	This module is the sub level RTL code of SDRAM Controller ASIC verilog
 code. It will generate the internal refresh counter.


 Hossein Amidi
 (C) April 2002

*********************************************************/

// DEFINES
`timescale 1ns / 10ps
module ref_timer(// Input
						reset,
						clk0,
						refresh_count,
						bur_len,
						ref_ack,
						// Output
						ref_req
						);

// Parameter
`include        "parameter.v"

// Input
input reset;
input clk0;
input [15:0]refresh_count;
input [burst_size - 1 : 0]bur_len;
input ref_ack;

// Output
output ref_req;

// Internal wire and reg signals
reg ref_req;

reg [15:0]refresh_timer;			// 16-bit refresh counter Max. 65536
reg rftimer_zero;


// Assignment


// Refresh Timer
always @(posedge reset or posedge clk0)
begin
	if(reset == 1'b1)
	begin
		refresh_timer <= 16'h0000;
		rftimer_zero  <= 1'b0;
		ref_req       <= 1'b0;
	end
	else
	begin
		if(rftimer_zero == 1'b1)
			refresh_timer <= refresh_count;
		else
			if(bur_len != 3'b000)
				refresh_timer <= refresh_timer - 1'b1;
			if((refresh_timer == 0) & (bur_len != 3'b000))
			begin
				rftimer_zero <= 1'b1;
				ref_req <= 1'b1;
			end
			else
				if(ref_ack == 1'b1)
				begin
					rftimer_zero <= 1'b0;
					ref_req <= 1'b0;
				end
	end
end


endmodule
