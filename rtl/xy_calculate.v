`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:17:56 04/15/2009 
// Design Name: 
// Module Name:    xy_calculate 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module xy_calculate(
		clk,
		RST,
		east,
		west,
		north,
		south,
		knob,
		 X,
		 Y,
		 enter
    );

input clk;
input RST;
input east;
input west;
input north;
input south;
input knob;

output [2:0] X;
output [2:0] Y;
output [0:0] enter;
reg [2:0] X;
reg [2:0] Y;
reg [22:0] Z;
reg [0:0] enter;
 
 wire btn_pulse;
 assign btn_pulse = &Z;
 
 
 always @(posedge clk) begin
	if ( RST ) begin
		Z <= 0;
		X <= 0;
		Y <= 0;
		enter <= 0;
	end 
	else begin
		Z <= Z + 1;
		
		if ( btn_pulse ) begin
			if ( east ) begin
				X <= X - 1;	
			end
			else
			if ( west ) begin
				X <= X + 1;	
			end
			else
			if ( north ) begin
				Y <= Y + 1;	
			end
			else
			if ( south ) begin
				Y <= Y - 1;	
			end
			else
			if ( knob ) begin
				enter <= 1;
			end
			else begin
				X <= X;
				Y <= Y;
				enter <= 0;
			end
		end
		else begin
			X <= X;
			Y <= Y;
			enter <= 0;
		end
	end
 end

endmodule
