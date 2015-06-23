`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:       Universidad Pontificia Bolivariana
// Engineer:      Fabio Andres Guzman Figueroa
// 
// Create Date:    08:18:51 05/10/2012 
// Design Name: 
// Module Name:    vga_control 
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
module vga_control(
    input clk,
    input rst,
	 input [2:0] ncolor,
    output reg hs, vs,
	 output [2:0] color,
    output [12:0] addrb
    );

reg [9:0] hcnt;
reg [8:0] vcnt;
reg clk25;

reg hsync, vsync;
wire [6:0] x;
wire [5:0] y;
wire blank;

//FF Toggle 
always@(posedge clk or posedge rst)
	if (rst)
		clk25<=0;
	else
		clk25<=~clk25;

//col counter [0->799]
always@(posedge clk25 or posedge rst)
	if (rst)
		hcnt<=0;
	else
		if (hcnt<800)
			hcnt<=hcnt+1;
		else
			hcnt<=0;

//row counter [0->523]
always@(posedge clk25 or posedge rst)
	if (rst)
		vcnt<=0;
	else
		if (hcnt==0)
			if (vcnt<524)
				vcnt<=vcnt+1;
			else
			   vcnt<=0;

// hsync pulse generation
always@(posedge clk25 or posedge rst)
	if (rst)
		hsync<=1;
	else
		if (hcnt>=656 && hcnt<752)
			hsync<=0;
		else
			hsync<=1;

//vsync pulse generation
always@(posedge clk25 or posedge rst)
	if (rst)
		vsync<=1;
	else
		if (vcnt>=491 && vcnt<493)
			vsync<=0;
		else
			vsync<=1;

assign blank=(hcnt>=640 || vcnt>=480)? 1: 0;

always@(posedge clk or posedge rst)
	if (rst) 
		begin
			hs<=1;
			vs<=1; 
		end
	else 
		begin
			hs<=hsync;
			vs<=vsync;
		end

assign color=blank? 0: ncolor;
			
//we change format dividing by 4, slicing from 640x480 to 80x60
assign x=hcnt[9:3];
assign y=vcnt[8:3];
assign addrb={y, x};


endmodule
