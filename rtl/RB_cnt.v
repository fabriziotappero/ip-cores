`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:44:58 05/05/2009 
// Design Name: 
// Module Name:    RB_cnt 
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
module RB_cnt(
		clk,
		RST,
		B,
		R,
		cntB,
		cntR
    );
	 
input clk;
input RST;
input [63:0] B;
input [63:0] R;
output [6:0] cntB;
output [6:0] cntR;

reg [3:0] cntB_p00_d;
reg [3:0] cntB_p01_d;
reg [3:0] cntB_p02_d;
reg [3:0] cntB_p03_d;
reg [3:0] cntB_p04_d;
reg [3:0] cntB_p05_d;
reg [3:0] cntB_p06_d;
reg [3:0] cntB_p07_d;

reg [3:0] cntR_p00_d;
reg [3:0] cntR_p01_d;
reg [3:0] cntR_p02_d;
reg [3:0] cntR_p03_d;
reg [3:0] cntR_p04_d;
reg [3:0] cntR_p05_d;
reg [3:0] cntR_p06_d;
reg [3:0] cntR_p07_d;

reg [6:0] cntB_d;
reg [6:0] cntR_d;

reg [6:0] cntB_q;
reg [6:0] cntR_q;

wire [6:0] cntR;
wire [6:0] cntB;

assign cntB = cntB_q;
assign cntR = cntR_q;

always @( * ) begin

	cntB_p00_d = B[00] + B[01] + B[02] + B[03] + B[04] + B[05] + B[06] + B[07];
	cntB_p01_d = B[08] + B[09] + B[10] + B[11] + B[12] + B[13] + B[14] + B[15];	
	cntB_p02_d = B[16] + B[17] + B[18] + B[19] + B[20] + B[21] + B[22] + B[23];
	cntB_p03_d = B[24] + B[25] + B[26] + B[27] + B[28] + B[29] + B[30] + B[31];
	cntB_p04_d = B[32] + B[33] + B[34] + B[35] + B[36] + B[37] + B[38] + B[39];
	cntB_p05_d = B[40] + B[41] + B[42] + B[43] + B[44] + B[45] + B[46] + B[47];
	cntB_p06_d = B[48] + B[49] + B[50] + B[51] + B[52] + B[53] + B[54] + B[55];
	cntB_p07_d = B[56] + B[57] + B[58] + B[59] + B[60] + B[61] + B[62] + B[63];
	
	cntB_d = cntB_p00_d + cntB_p01_d + cntB_p02_d + cntB_p03_d + cntB_p04_d + cntB_p05_d + cntB_p06_d + cntB_p07_d;

	cntR_p00_d = R[00] + R[01] + R[02] + R[03] + R[04] + R[05] + R[06] + R[07];
	cntR_p01_d = R[08] + R[09] + R[10] + R[11] + R[12] + R[13] + R[14] + R[15];	
	cntR_p02_d = R[16] + R[17] + R[18] + R[19] + R[20] + R[21] + R[22] + R[23];
	cntR_p03_d = R[24] + R[25] + R[26] + R[27] + R[28] + R[29] + R[30] + R[31];
	cntR_p04_d = R[32] + R[33] + R[34] + R[35] + R[36] + R[37] + R[38] + R[39];
	cntR_p05_d = R[40] + R[41] + R[42] + R[43] + R[44] + R[45] + R[46] + R[47];
	cntR_p06_d = R[48] + R[49] + R[50] + R[51] + R[52] + R[53] + R[54] + R[55];
	cntR_p07_d = R[56] + R[57] + R[58] + R[59] + R[60] + R[61] + R[62] + R[63];
	
	cntR_d = cntR_p00_d + cntR_p01_d + cntR_p02_d + cntR_p03_d + cntR_p04_d + cntR_p05_d + cntR_p06_d + cntR_p07_d;


end

always @(posedge clk) begin
	if ( RST ) begin
		cntB_q <= 0;
		cntR_q <= 0;
	end
	else begin
		cntB_q <= cntB_d;	
		cntR_q <= cntR_d;
	end
end

endmodule
