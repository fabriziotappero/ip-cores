//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : Inter_pred_CPE.v
// Generated : Oct 14, 2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Processing Element for Inter prediction of Chroma pixels
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module Inter_pred_CPE (xFracC,yFracC,
	Inter_C_window_0_0,Inter_C_window_1_0,Inter_C_window_2_0,
	Inter_C_window_0_1,Inter_C_window_1_1,Inter_C_window_2_1,
	Inter_C_window_0_2,Inter_C_window_1_2,Inter_C_window_2_2,
	CPE0_out,CPE1_out,CPE2_out,CPE3_out);
	input [2:0] xFracC,yFracC;
	input [7:0] Inter_C_window_0_0,Inter_C_window_1_0,Inter_C_window_2_0;
	input [7:0] Inter_C_window_0_1,Inter_C_window_1_1,Inter_C_window_2_1;
	input [7:0] Inter_C_window_0_2,Inter_C_window_1_2,Inter_C_window_2_2;
	output [7:0] CPE0_out,CPE1_out,CPE2_out,CPE3_out;
	
	wire [3:0] xFracC_n,yFracC_n;
	assign xFracC_n = 4'b1000 - xFracC;
	assign yFracC_n = 4'b1000 - yFracC;
	
	CPE CPE0 (
		.xFracC(xFracC),
		.yFracC(yFracC),
		.xFracC_n(xFracC_n),
		.yFracC_n(yFracC_n),
		.a(Inter_C_window_0_0),
		.b(Inter_C_window_1_0),
		.c(Inter_C_window_0_1),
		.d(Inter_C_window_1_1),
		.out(CPE0_out)
		);
	CPE CPE1 (
		.xFracC(xFracC),
		.yFracC(yFracC),
		.xFracC_n(xFracC_n),
		.yFracC_n(yFracC_n),
		.a(Inter_C_window_1_0),
		.b(Inter_C_window_2_0),
		.c(Inter_C_window_1_1),
		.d(Inter_C_window_2_1),
		.out(CPE1_out)
		); 
	CPE CPE2 (
		.xFracC(xFracC),
		.yFracC(yFracC),
		.xFracC_n(xFracC_n),
		.yFracC_n(yFracC_n),
		.a(Inter_C_window_0_1),
		.b(Inter_C_window_1_1),
		.c(Inter_C_window_0_2),
		.d(Inter_C_window_1_2),
		.out(CPE2_out)
		); 
	CPE CPE3 (
		.xFracC(xFracC),
		.yFracC(yFracC),
		.xFracC_n(xFracC_n),
		.yFracC_n(yFracC_n),
		.a(Inter_C_window_1_1),
		.b(Inter_C_window_2_1),
		.c(Inter_C_window_1_2),
		.d(Inter_C_window_2_2),
		.out(CPE3_out)
		); 
endmodule						 

module CPE (xFracC,yFracC,xFracC_n,yFracC_n,a,b,c,d,out);
	input [2:0] xFracC,yFracC;
	input [3:0] xFracC_n,yFracC_n;
	input [7:0] a,b,c,d;
	output [7:0] out;
	
	wire [13:0] CPE_base0_out,CPE_base1_out,CPE_base2_out,CPE_base3_out;
	wire [13:0] out_tmp; 
	
	CPE_base CPE_base0 (
		.x(xFracC_n),
		.y(yFracC_n),
		.Int_pel(a),
		.out(CPE_base0_out)
		);
	CPE_base CPE_base1 (
		.x({1'b0,xFracC}),
		.y(yFracC_n),
		.Int_pel(b),
		.out(CPE_base1_out)
		); 
	CPE_base CPE_base2 (
		.x(xFracC_n),
		.y({1'b0,yFracC}),
		.Int_pel(c),
		.out(CPE_base2_out)
		);
	CPE_base CPE_base3 (
		.x({1'b0,xFracC}),
		.y({1'b0,yFracC}),
		.Int_pel(d),
		.out(CPE_base3_out)
		);
	assign out_tmp = (CPE_base0_out + CPE_base1_out) + (CPE_base2_out + CPE_base3_out) + 32;
	assign out = out_tmp[13:6];
endmodule

module CPE_base (x,y,Int_pel,out);
	input [3:0] x;	
	input [3:0] y;	
	input [7:0] Int_pel;
	output [13:0] out;
	
	wire [10:0] sum_x3;
	wire [9:0] sum_x2;
	wire [8:0] sum_x1;
	wire [7:0] sum_x0;
	wire [10:0] sum_x;
	
	wire [13:0] sum_y3;
	wire [12:0] sum_y2;
	wire [11:0] sum_y1;
	wire [10:0] sum_y0;
	
	assign sum_x3 = (x[3] == 1'b1)? {Int_pel,3'b0}:0;
	assign sum_x2 = (x[2] == 1'b1)? {Int_pel,2'b0}:0;
	assign sum_x1 = (x[1] == 1'b1)? {Int_pel,1'b0}:0;
	assign sum_x0 = (x[0] == 1'b1)? Int_pel:0; 
	assign sum_x = (sum_x3 + sum_x2) + (sum_x1 + sum_x0);
	
	assign sum_y3 = (y[3] == 1'b1)? {sum_x,3'b0}:0;
	assign sum_y2 = (y[2] == 1'b1)? {sum_x,2'b0}:0;
	assign sum_y1 = (y[1] == 1'b1)? {sum_x,1'b0}:0;
	assign sum_y0 = (y[0] == 1'b1)? sum_x:0; 
	assign out = (sum_y3 + sum_y2) + (sum_y1 + sum_y0);
endmodule
	
	
	
	
	
	