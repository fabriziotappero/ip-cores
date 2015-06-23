`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:       Universidad Pontificia Bolivariana
// Engineer:      Fabio Andres Guzman Figueroa
// 
// Create Date:    18:55:46 05/14/2012 
// Design Name: 
// Module Name:    data_path 
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
module data_path(
    input clk,
    input rst,
    input [7:0] data_in,
    input insel,
    input we,
    input [2:0] raa,
    input [2:0] rab,
    input [2:0] wa,
    input [2:0] opalu,
    input [2:0] sh,
    input selpc,
	 input selk,
    input ldpc,
	 input ldflag,
	 input wr_en, rd_en,
	 input [10:0] ninst_addr,
	 input [7:0] kte,
	 input [7:0] imm,
	 input selimm,
    output [7:0] data_out,
    output [10:0] inst_addr,
	 output [10:0] stack_addr,
	 output reg z,c
    );

wire [7:0] regmux, muxkte, muximm;
wire [7:0] portA, portB;
wire [7:0] aluresu;
wire zero,carry;
wire [7:0] shiftout;

reg [10:0] PC;
wire [10:0] fifo_out;

regfile registros(regmux,clk,we,wa,raa,rab,portA,portB);
ALU alui(portA,muximm,aluresu,opalu,zero,carry);
shiftbyte shif_reg(aluresu,shiftout,sh);
LIFO LIFOi(clk,rst,wr_en,rd_en,PC,fifo_out);

assign stack_addr=fifo_out+1;
assign regmux=insel? shiftout : muxkte;
assign muxkte=selk? kte : data_in;
assign muximm=selimm? imm : portB;

always@(posedge clk or posedge rst)
	if (rst)
		begin
			z<=0;
			c<=0;
		end
	else
		if (ldflag)	
			begin
				z<=zero;
				c<=carry;
			end

always@(posedge clk or posedge rst)
	if (rst)
		PC<=0;
	else
		if (ldpc)	
			if(selpc)
				PC<=ninst_addr;
			else
				PC<=PC+1;

assign inst_addr=PC;
assign data_out=shiftout;

endmodule