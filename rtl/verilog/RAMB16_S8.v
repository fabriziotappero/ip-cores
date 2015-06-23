`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Chinthaka A.K.
// 
// Create Date:    06:35:12 12/08/2009 
// Design Name: 
// Module Name:    RAMB16_S8 
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
module RAMB16_S8(CLK,EN,WE,ADDR,DI,DO);
	input CLK;
	input EN;
	input WE;
	input [10:0] ADDR;
	input [7:0] DI;
	output [7:0] DO;

	reg [7:0] RAM [2047:0];
	reg [10:0] REG_ADDR;
	
	// initialize memory
	reg [11:0]count;
	
	initial begin
		for (count=0;count<2048;count=count+1) RAM[count]=0;
	end

	always @(negedge CLK) 
		begin
			if (EN)
				begin
					if (WE) RAM[ADDR] <= DI;
					
					REG_ADDR <= ADDR;
				end
		end	
	assign DO = RAM[REG_ADDR];

endmodule
