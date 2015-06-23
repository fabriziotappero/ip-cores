`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:05:40 04/28/2009 
// Design Name: 
// Module Name:    heuristics 
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
module heuristics(clk, RST, R, B, M, value/*, pattern_dbg1*/);
input clk;
input RST;
input [63:0] R;
input [63:0] B;
input [63:0] M;
output signed [19:0] value;
//output signed [4:0] pattern_dbg1;


reg signed [19:0] value_d;
reg signed [19:0] value_q;
reg signed [6:0] value_Rp0_d;
reg signed [6:0] value_Rp1_d;
reg signed [6:0] value_Rp2_d;
reg signed [6:0] value_Rp3_d;
reg signed [6:0] value_Rp4_d;
reg signed [6:0] value_Rp5_d;
reg signed [6:0] value_Rp6_d;
reg signed [6:0] value_Rp7_d;
reg signed [6:0] value_Rp8_d;
reg signed [6:0] value_Rp9_d;
reg signed [6:0] value_Rp10_d;
reg signed [6:0] value_Rp11_d;
reg signed [6:0] value_Bp0_d;
reg signed [6:0] value_Bp1_d;
reg signed [6:0] value_Bp2_d;
reg signed [6:0] value_Bp3_d;
reg signed [6:0] value_Bp4_d;
reg signed [6:0] value_Bp5_d;
reg signed [6:0] value_Bp6_d;
reg signed [6:0] value_Bp7_d;
reg signed [6:0] value_Bp8_d;
reg signed [6:0] value_Bp9_d;
reg signed [6:0] value_Bp10_d;
reg signed [6:0] value_Bp11_d;


reg signed [8:0] value_pp0_d;
reg signed [8:0] value_pp1_d;
reg signed [8:0] value_pp2_d;
reg signed [8:0] value_pp3_d;
reg signed [8:0] value_pp4_d;
reg signed [8:0] value_pp5_d;


wire signed [4:0] pattern00_Rd;
wire signed [4:0] pattern01_Rd;
wire signed [4:0] pattern02_Rd;
wire signed [4:0] pattern03_Rd;
wire signed [4:0] pattern04_Rd;
wire signed [4:0] pattern05_Rd;
wire signed [4:0] pattern06_Rd;
wire signed [4:0] pattern07_Rd;
wire signed [4:0] pattern08_Rd;
wire signed [4:0] pattern09_Rd;
wire signed [4:0] pattern10_Rd;
wire signed [4:0] pattern11_Rd;
wire signed [4:0] pattern12_Rd;
wire signed [4:0] pattern13_Rd;
wire signed [4:0] pattern14_Rd;
wire signed [4:0] pattern15_Rd;
wire signed [4:0] pattern16_Rd;
wire signed [4:0] pattern17_Rd;
wire signed [4:0] pattern18_Rd;
wire signed [4:0] pattern19_Rd;
wire signed [4:0] pattern20_Rd;
wire signed [4:0] pattern21_Rd;
wire signed [4:0] pattern22_Rd;
wire signed [4:0] pattern23_Rd;
wire signed [4:0] pattern24_Rd;
wire signed [4:0] pattern25_Rd;
wire signed [4:0] pattern26_Rd;
wire signed [4:0] pattern27_Rd;
wire signed [4:0] pattern28_Rd;
wire signed [4:0] pattern29_Rd;
wire signed [4:0] pattern30_Rd;
wire signed [4:0] pattern31_Rd;
wire signed [4:0] pattern32_Rd;
wire signed [4:0] pattern33_Rd;
wire signed [4:0] pattern34_Rd;
wire signed [4:0] pattern35_Rd;
wire signed [4:0] pattern36_Rd;
wire signed [4:0] pattern37_Rd;
wire signed [4:0] pattern38_Rd;
wire signed [4:0] pattern39_Rd;
wire signed [4:0] pattern40_Rd;
wire signed [4:0] pattern41_Rd;
wire signed [4:0] pattern42_Rd;
wire signed [4:0] pattern43_Rd;
wire signed [4:0] pattern44_Rd;
wire signed [4:0] pattern45_Rd;
wire signed [4:0] pattern46_Rd;
wire signed [4:0] pattern47_Rd;


wire signed [4:0] pattern00_Bd;
wire signed [4:0] pattern01_Bd;
wire signed [4:0] pattern02_Bd;
wire signed [4:0] pattern03_Bd;
wire signed [4:0] pattern04_Bd;
wire signed [4:0] pattern05_Bd;
wire signed [4:0] pattern06_Bd;
wire signed [4:0] pattern07_Bd;
wire signed [4:0] pattern08_Bd;
wire signed [4:0] pattern09_Bd;
wire signed [4:0] pattern10_Bd;
wire signed [4:0] pattern11_Bd;
wire signed [4:0] pattern12_Bd;
wire signed [4:0] pattern13_Bd;
wire signed [4:0] pattern14_Bd;
wire signed [4:0] pattern15_Bd;
wire signed [4:0] pattern16_Bd;
wire signed [4:0] pattern17_Bd;
wire signed [4:0] pattern18_Bd;
wire signed [4:0] pattern19_Bd;
wire signed [4:0] pattern20_Bd;
wire signed [4:0] pattern21_Bd;
wire signed [4:0] pattern22_Bd;
wire signed [4:0] pattern23_Bd;
wire signed [4:0] pattern24_Bd;
wire signed [4:0] pattern25_Bd;
wire signed [4:0] pattern26_Bd;
wire signed [4:0] pattern27_Bd;
wire signed [4:0] pattern28_Bd;
wire signed [4:0] pattern29_Bd;
wire signed [4:0] pattern30_Bd;
wire signed [4:0] pattern31_Bd;
wire signed [4:0] pattern32_Bd;
wire signed [4:0] pattern33_Bd;
wire signed [4:0] pattern34_Bd;
wire signed [4:0] pattern35_Bd;
wire signed [4:0] pattern36_Bd;
wire signed [4:0] pattern37_Bd;
wire signed [4:0] pattern38_Bd;
wire signed [4:0] pattern39_Bd;
wire signed [4:0] pattern40_Bd;
wire signed [4:0] pattern41_Bd;
wire signed [4:0] pattern42_Bd;
wire signed [4:0] pattern43_Bd;
wire signed [4:0] pattern44_Bd;
wire signed [4:0] pattern45_Bd;
wire signed [4:0] pattern46_Bd;
wire signed [4:0] pattern47_Bd;

//wire signed [4:0] pattern_dbg1 = pattern47_Bd;

assign pattern00_Rd = ((R[63:0] & 64'h0000000000000001) == 64'h0000000000000001) ?  1 : 0;
assign pattern00_Bd = ((B[63:0] & 64'h0000000000000001) == 64'h0000000000000001) ? -1 : 0;
assign pattern01_Rd = ((R[63:0] & 64'h0000000000000103) == 64'h0000000000000103) ?  2 : 0;
assign pattern01_Bd = ((B[63:0] & 64'h0000000000000103) == 64'h0000000000000103) ? -2 : 0;
assign pattern02_Rd = ((R[63:0] & 64'h0000000000010307) == 64'h0000000000010307) ?  3 : 0;
assign pattern02_Bd = ((B[63:0] & 64'h0000000000010307) == 64'h0000000000010307) ? -3 : 0;
assign pattern03_Rd = ((R[63:0] & 64'h000000000103070F) == 64'h000000000103070F) ?  4 : 0;
assign pattern03_Bd = ((B[63:0] & 64'h000000000103070F) == 64'h000000000103070F) ? -4 : 0;
assign pattern04_Rd = ((R[63:0] & 64'h0000000103070F1F) == 64'h0000000103070F1F) ?  5 : 0;
assign pattern04_Bd = ((B[63:0] & 64'h0000000103070F1F) == 64'h0000000103070F1F) ? -5 : 0;
assign pattern05_Rd = ((R[63:0] & 64'h00000103070F1F3F) == 64'h00000103070F1F3F) ?  6 : 0;
assign pattern05_Bd = ((B[63:0] & 64'h00000103070F1F3F) == 64'h00000103070F1F3F) ? -6 : 0;
assign pattern06_Rd = ((R[63:0] & 64'h000103070F1F3F7F) == 64'h000103070F1F3F7F) ?  7 : 0;
assign pattern06_Bd = ((B[63:0] & 64'h000103070F1F3F7F) == 64'h000103070F1F3F7F) ? -7 : 0;
assign pattern07_Rd = ((R[63:0] & 64'h0103070F1F3F7FFF) == 64'h0103070F1F3F7FFF) ?  8 : 0;
assign pattern07_Bd = ((B[63:0] & 64'h0103070F1F3F7FFF) == 64'h0103070F1F3F7FFF) ? -8 : 0;
assign pattern08_Rd = ((R[63:0] & 64'h0000000000000080) == 64'h0000000000000080) ?  1 : 0;
assign pattern08_Bd = ((B[63:0] & 64'h0000000000000080) == 64'h0000000000000080) ? -1 : 0;
assign pattern09_Rd = ((R[63:0] & 64'h00000000000080C0) == 64'h00000000000080C0) ?  2 : 0;
assign pattern09_Bd = ((B[63:0] & 64'h00000000000080C0) == 64'h00000000000080C0) ? -2 : 0;
assign pattern10_Rd = ((R[63:0] & 64'h000000000080C0E0) == 64'h000000000080C0E0) ?  3 : 0;
assign pattern10_Bd = ((B[63:0] & 64'h000000000080C0E0) == 64'h000000000080C0E0) ? -3 : 0;
assign pattern11_Rd = ((R[63:0] & 64'h0000000080C0E0F0) == 64'h0000000080C0E0F0) ?  4 : 0;
assign pattern11_Bd = ((B[63:0] & 64'h0000000080C0E0F0) == 64'h0000000080C0E0F0) ? -4 : 0;
assign pattern12_Rd = ((R[63:0] & 64'h00000080C0E0F0F8) == 64'h00000080C0E0F0F8) ?  5 : 0;
assign pattern12_Bd = ((B[63:0] & 64'h00000080C0E0F0F8) == 64'h00000080C0E0F0F8) ? -5 : 0;
assign pattern13_Rd = ((R[63:0] & 64'h000080C0E0F0F8FC) == 64'h000080C0E0F0F8FC) ?  6 : 0;
assign pattern13_Bd = ((B[63:0] & 64'h000080C0E0F0F8FC) == 64'h000080C0E0F0F8FC) ? -6 : 0;
assign pattern14_Rd = ((R[63:0] & 64'h0080C0E0F0F8FCFE) == 64'h0080C0E0F0F8FCFE) ?  7 : 0;
assign pattern14_Bd = ((B[63:0] & 64'h0080C0E0F0F8FCFE) == 64'h0080C0E0F0F8FCFE) ? -7 : 0;
assign pattern15_Rd = ((R[63:0] & 64'h80C0E0F0F8FCFEFF) == 64'h80C0E0F0F8FCFEFF) ?  8 : 0;
assign pattern15_Bd = ((B[63:0] & 64'h80C0E0F0F8FCFEFF) == 64'h80C0E0F0F8FCFEFF) ? -8 : 0;
assign pattern16_Rd = ((R[63:0] & 64'h8000000000000000) == 64'h8000000000000000) ?  1 : 0;
assign pattern16_Bd = ((B[63:0] & 64'h8000000000000000) == 64'h8000000000000000) ? -1 : 0;
assign pattern17_Rd = ((R[63:0] & 64'hC080000000000000) == 64'hC080000000000000) ?  2 : 0;
assign pattern17_Bd = ((B[63:0] & 64'hC080000000000000) == 64'hC080000000000000) ? -2 : 0;
assign pattern18_Rd = ((R[63:0] & 64'hE0C0800000000000) == 64'hE0C0800000000000) ?  3 : 0;
assign pattern18_Bd = ((B[63:0] & 64'hE0C0800000000000) == 64'hE0C0800000000000) ? -3 : 0;
assign pattern19_Rd = ((R[63:0] & 64'hF0E0C08000000000) == 64'hF0E0C08000000000) ?  4 : 0;
assign pattern19_Bd = ((B[63:0] & 64'hF0E0C08000000000) == 64'hF0E0C08000000000) ? -4 : 0;
assign pattern20_Rd = ((R[63:0] & 64'hF8F0E0C080000000) == 64'hF8F0E0C080000000) ?  5 : 0;
assign pattern20_Bd = ((B[63:0] & 64'hF8F0E0C080000000) == 64'hF8F0E0C080000000) ? -5 : 0;
assign pattern21_Rd = ((R[63:0] & 64'hFCF8F0E0C0800000) == 64'hFCF8F0E0C0800000) ?  6 : 0;
assign pattern21_Bd = ((B[63:0] & 64'hFCF8F0E0C0800000) == 64'hFCF8F0E0C0800000) ? -6 : 0;
assign pattern22_Rd = ((R[63:0] & 64'hFEFCF8F0E0C08000) == 64'hFEFCF8F0E0C08000) ?  7 : 0;
assign pattern22_Bd = ((B[63:0] & 64'hFEFCF8F0E0C08000) == 64'hFEFCF8F0E0C08000) ? -7 : 0;
assign pattern23_Rd = ((R[63:0] & 64'hFFFEFCF8F0E0C080) == 64'hFFFEFCF8F0E0C080) ?  8 : 0;
assign pattern23_Bd = ((B[63:0] & 64'hFFFEFCF8F0E0C080) == 64'hFFFEFCF8F0E0C080) ? -8 : 0;
assign pattern24_Rd = ((R[63:0] & 64'h0100000000000000) == 64'h0100000000000000) ?  1 : 0;
assign pattern24_Bd = ((B[63:0] & 64'h0100000000000000) == 64'h0100000000000000) ? -1 : 0;
assign pattern25_Rd = ((R[63:0] & 64'h0301000000000000) == 64'h0301000000000000) ?  2 : 0;
assign pattern25_Bd = ((B[63:0] & 64'h0301000000000000) == 64'h0301000000000000) ? -2 : 0;
assign pattern26_Rd = ((R[63:0] & 64'h0703010000000000) == 64'h0703010000000000) ?  3 : 0;
assign pattern26_Bd = ((B[63:0] & 64'h0703010000000000) == 64'h0703010000000000) ? -3 : 0;
assign pattern27_Rd = ((R[63:0] & 64'h0F07030100000000) == 64'h0F07030100000000) ?  4 : 0;
assign pattern27_Bd = ((B[63:0] & 64'h0F07030100000000) == 64'h0F07030100000000) ? -4 : 0;
assign pattern28_Rd = ((R[63:0] & 64'h1F0F070301000000) == 64'h1F0F070301000000) ?  5 : 0;
assign pattern28_Bd = ((B[63:0] & 64'h1F0F070301000000) == 64'h1F0F070301000000) ? -5 : 0;
assign pattern29_Rd = ((R[63:0] & 64'h3F1F0F0703010000) == 64'h3F1F0F0703010000) ?  6 : 0;
assign pattern29_Bd = ((B[63:0] & 64'h3F1F0F0703010000) == 64'h3F1F0F0703010000) ? -6 : 0;
assign pattern30_Rd = ((R[63:0] & 64'h7F3F1F0F07030100) == 64'h7F3F1F0F07030100) ?  7 : 0;
assign pattern30_Bd = ((B[63:0] & 64'h7F3F1F0F07030100) == 64'h7F3F1F0F07030100) ? -7 : 0;
assign pattern31_Rd = ((R[63:0] & 64'hFF7F3F1F0F070301) == 64'hFF7F3F1F0F070301) ?  8 : 0;
assign pattern31_Bd = ((B[63:0] & 64'hFF7F3F1F0F070301) == 64'hFF7F3F1F0F070301) ? -8 : 0;
assign pattern32_Rd = ((R[63:0] & 64'h0101010101010101) == 64'h0101010101010101) ?  3 : 0;
assign pattern32_Bd = ((B[63:0] & 64'h0101010101010101) == 64'h0101010101010101) ? -3 : 0;
assign pattern33_Rd = ((R[63:0] & 64'h0303030303030303) == 64'h0303030303030303) ?  5 : 0;
assign pattern33_Bd = ((B[63:0] & 64'h0303030303030303) == 64'h0303030303030303) ? -5 : 0;
assign pattern34_Rd = ((R[63:0] & 64'h0707070707070707) == 64'h0707070707070707) ?  7 : 0;
assign pattern34_Bd = ((B[63:0] & 64'h0707070707070707) == 64'h0707070707070707) ? -7 : 0;
assign pattern35_Rd = ((R[63:0] & 64'h0F0F0F0F0F0F0F0F) == 64'h0F0F0F0F0F0F0F0F) ?  10 : 0;
assign pattern35_Bd = ((B[63:0] & 64'h0F0F0F0F0F0F0F0F) == 64'h0F0F0F0F0F0F0F0F) ? -10 : 0;
assign pattern36_Rd = ((R[63:0] & 64'h8080808080808080) == 64'h8080808080808080) ?  3 : 0;
assign pattern36_Bd = ((B[63:0] & 64'h8080808080808080) == 64'h8080808080808080) ? -3 : 0;
assign pattern37_Rd = ((R[63:0] & 64'hC0C0C0C0C0C0C0C0) == 64'hC0C0C0C0C0C0C0C0) ?  5 : 0;
assign pattern37_Bd = ((B[63:0] & 64'hC0C0C0C0C0C0C0C0) == 64'hC0C0C0C0C0C0C0C0) ? -5 : 0;
assign pattern38_Rd = ((R[63:0] & 64'hE0E0E0E0E0E0E0E0) == 64'hE0E0E0E0E0E0E0E0) ?  7 : 0;
assign pattern38_Bd = ((B[63:0] & 64'hE0E0E0E0E0E0E0E0) == 64'hE0E0E0E0E0E0E0E0) ? -7 : 0;
assign pattern39_Rd = ((R[63:0] & 64'hF0F0F0F0F0F0F0F0) == 64'hF0F0F0F0F0F0F0F0) ?  10 : 0;
assign pattern39_Bd = ((B[63:0] & 64'hF0F0F0F0F0F0F0F0) == 64'hF0F0F0F0F0F0F0F0) ? -10 : 0;
assign pattern40_Rd = ((R[63:0] & 64'h00000000000000FF) == 64'h00000000000000FF) ?  3 : 0;
assign pattern40_Bd = ((B[63:0] & 64'h00000000000000FF) == 64'h00000000000000FF) ? -3 : 0;
assign pattern41_Rd = ((R[63:0] & 64'h000000000000FFFF) == 64'h000000000000FFFF) ?  5 : 0;
assign pattern41_Bd = ((B[63:0] & 64'h000000000000FFFF) == 64'h000000000000FFFF) ? -5 : 0;
assign pattern42_Rd = ((R[63:0] & 64'h0000000000FFFFFF) == 64'h0000000000FFFFFF) ?  7 : 0;
assign pattern42_Bd = ((B[63:0] & 64'h0000000000FFFFFF) == 64'h0000000000FFFFFF) ? -7 : 0;
assign pattern43_Rd = ((R[63:0] & 64'h00000000FFFFFFFF) == 64'h00000000FFFFFFFF) ?  10 : 0;
assign pattern43_Bd = ((B[63:0] & 64'h00000000FFFFFFFF) == 64'h00000000FFFFFFFF) ? -10 : 0;
assign pattern44_Rd = ((R[63:0] & 64'hFFFFFFFF00000000) == 64'hFFFFFFFF00000000) ?  10 : 0;
assign pattern44_Bd = ((B[63:0] & 64'hFFFFFFFF00000000) == 64'hFFFFFFFF00000000) ? -10 : 0;
assign pattern45_Rd = ((R[63:0] & 64'hFFFFFF0000000000) == 64'hFFFFFF0000000000) ?  7 : 0;
assign pattern45_Bd = ((B[63:0] & 64'hFFFFFF0000000000) == 64'hFFFFFF0000000000) ? -7 : 0;
assign pattern46_Rd = ((R[63:0] & 64'hFFFF000000000000) == 64'hFFFF000000000000) ?  5 : 0;
assign pattern46_Bd = ((B[63:0] & 64'hFFFF000000000000) == 64'hFFFF000000000000) ? -5 : 0;
assign pattern47_Rd = ((R[63:0] & 64'hFF00000000000000) == 64'hFF00000000000000) ?  3 : 0;
assign pattern47_Bd = ((B[63:0] & 64'hFF00000000000000) == 64'hFF00000000000000) ? -3 : 0;

//wire [5:0] mutability;


//cntB_d = cntB_p00_d + cntB_p01_d + cntB_p02_d + cntB_p03_d + cntB_p04_d + cntB_p05_d + cntB_p06_d + cntB_p07_d;

//assign mutability = M[0] + M[1] + M[2] + M[3] + M[4] + M[5] + M[6] + M[7] + M[8] + M[9] + M[10] + M[11] + M[12] + M[13] + M[14] + M[15] + M[16] + M[17] + M[18] + M[19] + M[20] + M[21] + M[22] + M[23] + M[24] + M[25] + M[26] + M[27] + M[28] + M[29] + M[30] + M[31] + M[32] + M[33] + M[34] + M[35] + M[36] + M[37] + M[38] + M[39] + M[40] + M[41] + M[42] + M[43] + M[44] + M[45] + M[46] + M[47] + M[48] + M[49] + M[50] + M[51] + M[52] + M[53] + M[54] + M[55] + M[56] + M[57] + M[58] + M[59] + M[60] + M[61] + M[62] + M[63];


reg [3:0] cntM_p00_d;
reg [3:0] cntM_p01_d;
reg [3:0] cntM_p02_d;
reg [3:0] cntM_p03_d;
reg [3:0] cntM_p04_d;
reg [3:0] cntM_p05_d;
reg [3:0] cntM_p06_d;
reg [3:0] cntM_p07_d;

reg [6:0] mutability_d;


always @( * ) begin

	cntM_p00_d = M[00] + M[01] + M[02] + M[03] + M[04] + M[05] + M[06] + M[07];
	cntM_p01_d = M[08] + M[09] + M[10] + M[11] + M[12] + M[13] + M[14] + M[15];
	cntM_p02_d = M[16] + M[17] + M[18] + M[19] + M[20] + M[21] + M[22] + M[23];
	cntM_p03_d = M[24] + M[25] + M[26] + M[27] + M[28] + M[29] + M[30] + M[31];
	cntM_p04_d = M[32] + M[33] + M[34] + M[35] + M[36] + M[37] + M[38] + M[39];
	cntM_p05_d = M[40] + M[41] + M[42] + M[43] + M[44] + M[45] + M[46] + M[47];
	cntM_p06_d = M[48] + M[49] + M[50] + M[51] + M[52] + M[53] + M[54] + M[55];
	cntM_p07_d = M[56] + M[57] + M[58] + M[59] + M[60] + M[61] + M[62] + M[63];
	
	mutability_d = cntM_p00_d + cntM_p01_d + cntM_p02_d + cntM_p03_d + cntM_p04_d + cntM_p05_d + cntM_p06_d + cntM_p07_d;


	value_Rp0_d = pattern00_Rd + pattern01_Rd + pattern02_Rd + pattern03_Rd; 
	value_Rp1_d = pattern04_Rd + pattern05_Rd + pattern06_Rd + pattern07_Rd; 
	value_Rp2_d = pattern08_Rd + pattern09_Rd + pattern10_Rd + pattern11_Rd; 
	value_Rp3_d = pattern12_Rd + pattern13_Rd + pattern14_Rd + pattern15_Rd; 
	value_Rp4_d = pattern16_Rd + pattern17_Rd + pattern18_Rd + pattern19_Rd; 
	value_Rp5_d = pattern20_Rd + pattern21_Rd + pattern22_Rd + pattern23_Rd; 
	value_Rp6_d = pattern24_Rd + pattern25_Rd + pattern26_Rd + pattern27_Rd; 
	value_Rp7_d = pattern28_Rd + pattern29_Rd + pattern30_Rd + pattern31_Rd; 
	value_Rp8_d = pattern32_Rd + pattern33_Rd + pattern34_Rd + pattern35_Rd; 
	value_Rp9_d = pattern36_Rd + pattern37_Rd + pattern38_Rd + pattern39_Rd; 
	value_Rp10_d = pattern40_Rd + pattern41_Rd + pattern42_Rd + pattern43_Rd; 
	value_Rp11_d = pattern44_Rd + pattern45_Rd + pattern46_Rd + pattern47_Rd; 


	value_Bp0_d = pattern00_Bd + pattern01_Bd + pattern02_Bd + pattern03_Bd; 
	value_Bp1_d = pattern04_Bd + pattern05_Bd + pattern06_Bd + pattern07_Bd; 
	value_Bp2_d = pattern08_Bd + pattern09_Bd + pattern10_Bd + pattern11_Bd; 
	value_Bp3_d = pattern12_Bd + pattern13_Bd + pattern14_Bd + pattern15_Bd; 
	value_Bp4_d = pattern16_Bd + pattern17_Bd + pattern18_Bd + pattern19_Bd; 
	value_Bp5_d = pattern20_Bd + pattern21_Bd + pattern22_Bd + pattern23_Bd; 
	value_Bp6_d = pattern24_Bd + pattern25_Bd + pattern26_Bd + pattern27_Bd; 
	value_Bp7_d = pattern28_Bd + pattern29_Bd + pattern30_Bd + pattern31_Bd; 
	value_Bp8_d = pattern32_Bd + pattern33_Bd + pattern34_Bd + pattern35_Bd; 
	value_Bp9_d = pattern36_Bd + pattern37_Bd + pattern38_Bd + pattern39_Bd; 
	value_Bp10_d = pattern40_Bd + pattern41_Bd + pattern42_Bd + pattern43_Bd; 
	value_Bp11_d = pattern44_Bd + pattern45_Bd + pattern46_Bd + pattern47_Bd; 


	value_pp0_d = value_Rp0_d + value_Rp1_d + value_Rp2_d + value_Rp3_d; 
	value_pp1_d = value_Rp4_d + value_Rp5_d + value_Rp6_d + value_Rp7_d; 
	value_pp2_d = value_Rp8_d + value_Rp9_d + value_Rp10_d + value_Rp11_d; 
	value_pp3_d = value_Bp0_d + value_Bp1_d + value_Bp2_d + value_Bp3_d; 
	value_pp4_d = value_Bp4_d + value_Bp5_d + value_Bp6_d + value_Bp7_d; 
	value_pp5_d = value_Bp8_d + value_Bp9_d + value_Bp10_d + value_Bp11_d; 


value_d = value_pp0_d + value_pp1_d + value_pp2_d + value_pp3_d + value_pp4_d + value_pp5_d;
//value_d = value_d*64 + mutability_d*16;
value_d = value_d*64 + mutability_d*32;

/*

CHAIN METHOD
      value_d = (pattern00_d + pattern01_d + pattern02_d + pattern03_d + 
					 pattern04_d + pattern05_d + pattern06_d + pattern07_d + 
					 pattern08_d + pattern09_d + pattern10_d + pattern11_d + 
					 pattern12_d + pattern13_d + pattern14_d + pattern15_d + 
					 pattern16_d + pattern17_d + pattern18_d + pattern19_d + 
					 pattern20_d + pattern21_d + pattern22_d + pattern23_d + 
					 pattern24_d + pattern25_d + pattern26_d + pattern27_d + 
					 pattern28_d + pattern29_d + pattern30_d + pattern31_d + 
					 pattern32_d + pattern33_d + pattern34_d + pattern35_d + 
					 pattern36_d + pattern37_d + pattern38_d + pattern39_d + 
					 pattern40_d + pattern41_d + pattern42_d + pattern43_d + 
					 pattern44_d + pattern45_d + pattern46_d + pattern47_d) * 16;
					 
*/

end

always @(posedge clk) begin
    if ( RST ) begin
	     value_q <= 20'b0;
	 end
	 else begin
        value_q <= value_d;
	 end
end

assign value = value_q;

endmodule
