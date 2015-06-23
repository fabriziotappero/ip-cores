`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Chinthaka A.K.
// 
// Create Date:    10:14:47 12/08/2009 
// Design Name: 
// Module Name:    one_to_eight_demux_8bit 
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
module one_to_eight_demux_8bit(d,demux_in,select);
	output [63:0]d;
	input [7:0]demux_in;
	input [2:0]select;
	
	three_to_eight_decoder DEC0({d[0],d[8],d[16],d[24],d[32],d[40],d[48],d[56]},select,demux_in[0]);
	three_to_eight_decoder DEC1({d[1],d[9],d[17],d[25],d[33],d[41],d[49],d[57]},select,demux_in[1]);
	three_to_eight_decoder DEC2({d[2],d[10],d[18],d[26],d[34],d[42],d[50],d[58]},select,demux_in[2]);
	three_to_eight_decoder DEC3({d[3],d[11],d[19],d[27],d[35],d[43],d[51],d[59]},select,demux_in[3]);
	three_to_eight_decoder DEC4({d[4],d[12],d[20],d[28],d[36],d[44],d[52],d[60]},select,demux_in[4]);
	three_to_eight_decoder DEC5({d[5],d[13],d[21],d[29],d[37],d[45],d[53],d[61]},select,demux_in[5]);
	three_to_eight_decoder DEC6({d[6],d[14],d[22],d[30],d[38],d[46],d[54],d[62]},select,demux_in[6]);
	three_to_eight_decoder DEC7({d[7],d[15],d[23],d[31],d[39],d[47],d[55],d[63]},select,demux_in[7]);
	
endmodule
