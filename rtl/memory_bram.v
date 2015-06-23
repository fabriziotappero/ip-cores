`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:22:41 04/23/2009 
// Design Name: 
// Module Name:    memory_bram 
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
module memory_bram(clk, we, addr, DIN, DOUT);
input clk;
input we;
input [3:0] addr;

parameter MEM_SIZE = 256;
input [MEM_SIZE-1 :0] DIN;
output [MEM_SIZE-1 :0] DOUT;

reg [3:0] read_addr;
reg [MEM_SIZE - 1:0] bram [15:0];

always @(posedge clk) begin
	if ( we ) begin
		bram[addr] <= DIN;
	end
   read_addr <= addr;
end
	 
assign DOUT = bram[read_addr];
endmodule
