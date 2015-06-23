`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:51:25 11/25/2010 
// Design Name: 
// Module Name:    dpram 
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
module dpram(	in, 
					out, 
					adr,
					adw,
					clk, 
					rst, 
					frame_rst,
					en);

parameter		data_width			=	64;
parameter		ram_depth			=	256;
parameter		addr_width			=	8;

input		clk, rst, frame_rst, en;
input		[data_width-1:0]	in;
output	[data_width-1:0]	out;
wire		[data_width-1:0]	out;
input		[addr_width-1:0]	adr;
input		[addr_width-1:0]	adw;

reg		[data_width-1:0]	ram	[0:ram_depth-1];

assign out = ram[adr];

always @ (rst, en, clk, frame_rst)
begin
	if (!rst)
		$readmemb("rstmem.txt", ram);
	else if (clk && en && !frame_rst)
		ram[adw] = in;
end

endmodule
