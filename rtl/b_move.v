`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:47:59 04/05/2009 
// Design Name: 
// Module Name:    b_move 
// Project Name:   The FPGA Othello Game
// Target Devices: 
// Tool versions: 
// Description: 
//		Will actually make a move in a given Othello board.
//    Input: current board, (X,Y) - where to move, player
//    Output: modified board
//
//    What do we have here, is a completly board mesh. 8x64 cells connected.
//    64 cells for each direction (I-VIII). The result is combined from each 
//    direction output
//    Hope this method takes much less area then having only 64 cells but with
//    more complicated logic inside each cell. (4*8 inputs/outputs vs 4 inputs/outputs).
//
// Dependencies: 
//		move_cell
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//      Finally, combinational method....
//
//  Marius TIVADAR Mar-Apr, 2009
//////////////////////////////////////////////////////////////////////////////////

module b_move(clk, player, RST, R_, B_, X, Y, R_OUT, B_OUT);
input clk;
input [63:0] R_;
input [63:0] B_;
input [2:0] X;
input [2:0] Y;
input player;
input RST;

output [63:0] R_OUT;
output [63:0] B_OUT;

wire [63:0] R;
wire [63:0] B;

/* internal wires, output from board cells */

reg [63:0] R_OUT_D;
reg [63:0] B_OUT_D;
wire [63:0] R_OUT_D0;
wire [63:0] B_OUT_D0;

wire [63:0] R_OUT_D1;
wire [63:0] B_OUT_D1;

wire [63:0] R_OUT_D2;
wire [63:0] B_OUT_D2;

wire [63:0] R_OUT_D3;
wire [63:0] B_OUT_D3;

wire [63:0] R_OUT_D4;
wire [63:0] B_OUT_D4;

wire [63:0] R_OUT_D5;
wire [63:0] B_OUT_D5;

wire [63:0] R_OUT_D6;
wire [63:0] B_OUT_D6;

wire [63:0] R_OUT_D7;
wire [63:0] B_OUT_D7;

/* output board, registered */
reg [63:0] R_OUT_Q;
reg [63:0] B_OUT_Q;

/* mesh wires */
wire [63:0] wbw_out0;
wire [63:0] wfw_out0;

wire [63:0] wbw_out1;
wire [63:0] wfw_out1;

wire [63:0] wbw_out2;
wire [63:0] wfw_out2;

wire [63:0] wbw_out3;
wire [63:0] wfw_out3;

wire [63:0] wbw_out4;
wire [63:0] wfw_out4;

wire [63:0] wbw_out5;
wire [63:0] wfw_out5;

wire [63:0] wbw_out6;
wire [63:0] wfw_out6;

wire [63:0] wbw_out7;
wire [63:0] wfw_out7;

/* Directions:                     */
/*    I - horizontal right         */
/*   II - horizontal left          */
/*  III - vertical up              */
/*   IV - vertical down            */
/*    V - diagonal right-up        */
/*   VI - diagonal left-down       */
/*  VII - diagonal right-down      */
/* VIII - diagonal left-up         */

/* Direction I : */
generate
genvar i1;
  for (i1 = 0; i1 < 8; i1=i1+1) begin:mcell
		move_cell m0(.r(R[0 + i1*8]), .b(B[0 + i1*8]), .fw_in(wfw_out0[1 + i1*8]), .bw_in(1'b0)              , .bw_out(wbw_out0[0 + i1*8]), .fw_out(wfw_out0[0 + i1*8]), .pulse((X == 0) && (Y == i1)), .r_out(R_OUT_D0[0 + i1*8]), .b_out(B_OUT_D0[0 + i1*8]) );
		move_cell m1(.r(R[1 + i1*8]), .b(B[1 + i1*8]), .fw_in(wfw_out0[2 + i1*8]), .bw_in(wbw_out0[0 + i1*8]), .bw_out(wbw_out0[1 + i1*8]), .fw_out(wfw_out0[1 + i1*8]), .pulse((X == 1) && (Y == i1)), .r_out(R_OUT_D0[1 + i1*8]), .b_out(B_OUT_D0[1 + i1*8]) );
		move_cell m2(.r(R[2 + i1*8]), .b(B[2 + i1*8]), .fw_in(wfw_out0[3 + i1*8]), .bw_in(wbw_out0[1 + i1*8]), .bw_out(wbw_out0[2 + i1*8]), .fw_out(wfw_out0[2 + i1*8]), .pulse((X == 2) && (Y == i1)), .r_out(R_OUT_D0[2 + i1*8]), .b_out(B_OUT_D0[2 + i1*8]) );
		move_cell m3(.r(R[3 + i1*8]), .b(B[3 + i1*8]), .fw_in(wfw_out0[4 + i1*8]), .bw_in(wbw_out0[2 + i1*8]), .bw_out(wbw_out0[3 + i1*8]), .fw_out(wfw_out0[3 + i1*8]), .pulse((X == 3) && (Y == i1)), .r_out(R_OUT_D0[3 + i1*8]), .b_out(B_OUT_D0[3 + i1*8]) );
		move_cell m4(.r(R[4 + i1*8]), .b(B[4 + i1*8]), .fw_in(wfw_out0[5 + i1*8]), .bw_in(wbw_out0[3 + i1*8]), .bw_out(wbw_out0[4 + i1*8]), .fw_out(wfw_out0[4 + i1*8]), .pulse((X == 4) && (Y == i1)), .r_out(R_OUT_D0[4 + i1*8]), .b_out(B_OUT_D0[4 + i1*8]) );
		move_cell m5(.r(R[5 + i1*8]), .b(B[5 + i1*8]), .fw_in(wfw_out0[6 + i1*8]), .bw_in(wbw_out0[4 + i1*8]), .bw_out(wbw_out0[5 + i1*8]), .fw_out(wfw_out0[5 + i1*8]), .pulse((X == 5) && (Y == i1)), .r_out(R_OUT_D0[5 + i1*8]), .b_out(B_OUT_D0[5 + i1*8]) );
		move_cell m6(.r(R[6 + i1*8]), .b(B[6 + i1*8]), .fw_in(wfw_out0[7 + i1*8]), .bw_in(wbw_out0[5 + i1*8]), .bw_out(wbw_out0[6 + i1*8]), .fw_out(wfw_out0[6 + i1*8]), .pulse((X == 6) && (Y == i1)), .r_out(R_OUT_D0[6 + i1*8]), .b_out(B_OUT_D0[6 + i1*8]) );
		move_cell m7(.r(R[7 + i1*8]), .b(B[7 + i1*8]), .fw_in(1'b0)              , .bw_in(wbw_out0[6 + i1*8]), .bw_out(wbw_out0[7 + i1*8]), .fw_out(wfw_out0[7 + i1*8]), .pulse((X == 7) && (Y == i1)), .r_out(R_OUT_D0[7 + i1*8]), .b_out(B_OUT_D0[7 + i1*8]) );
	end	
endgenerate

/* Direction II : */
generate
genvar i2;
  for (i2 = 0; i2 < 8; i2=i2+1) begin:mcell1
		move_cell m0(.r(R[0 + i2*8]), .b(B[0 + i2*8]), .fw_in(1'b0),                  .bw_in(wbw_out1[1 + i2*8]), .bw_out(wbw_out1[0 + i2*8]), .fw_out(wfw_out1[0 + i2*8]), .pulse((X == 0) && (Y == i2)), .r_out(R_OUT_D1[0 + i2*8]), .b_out(B_OUT_D1[0 + i2*8]) );
		move_cell m1(.r(R[1 + i2*8]), .b(B[1 + i2*8]), .fw_in(wfw_out1[0 + i2*8]), .bw_in(wbw_out1[2 + i2*8]), .bw_out(wbw_out1[1 + i2*8]), .fw_out(wfw_out1[1 + i2*8]), .pulse((X == 1) && (Y == i2)), .r_out(R_OUT_D1[1 + i2*8]), .b_out(B_OUT_D1[1 + i2*8]) );
		move_cell m2(.r(R[2 + i2*8]), .b(B[2 + i2*8]), .fw_in(wfw_out1[1 + i2*8]), .bw_in(wbw_out1[3 + i2*8]), .bw_out(wbw_out1[2 + i2*8]), .fw_out(wfw_out1[2 + i2*8]), .pulse((X == 2) && (Y == i2)), .r_out(R_OUT_D1[2 + i2*8]), .b_out(B_OUT_D1[2 + i2*8]) );
		move_cell m3(.r(R[3 + i2*8]), .b(B[3 + i2*8]), .fw_in(wfw_out1[2 + i2*8]), .bw_in(wbw_out1[4 + i2*8]), .bw_out(wbw_out1[3 + i2*8]), .fw_out(wfw_out1[3 + i2*8]), .pulse((X == 3) && (Y == i2)), .r_out(R_OUT_D1[3 + i2*8]), .b_out(B_OUT_D1[3 + i2*8]) );
		move_cell m4(.r(R[4 + i2*8]), .b(B[4 + i2*8]), .fw_in(wfw_out1[3 + i2*8]), .bw_in(wbw_out1[5 + i2*8]), .bw_out(wbw_out1[4 + i2*8]), .fw_out(wfw_out1[4 + i2*8]), .pulse((X == 4) && (Y == i2)), .r_out(R_OUT_D1[4 + i2*8]), .b_out(B_OUT_D1[4 + i2*8]) );
		move_cell m5(.r(R[5 + i2*8]), .b(B[5 + i2*8]), .fw_in(wfw_out1[4 + i2*8]), .bw_in(wbw_out1[6 + i2*8]), .bw_out(wbw_out1[5 + i2*8]), .fw_out(wfw_out1[5 + i2*8]), .pulse((X == 5) && (Y == i2)), .r_out(R_OUT_D1[5 + i2*8]), .b_out(B_OUT_D1[5 + i2*8]) );
		move_cell m6(.r(R[6 + i2*8]), .b(B[6 + i2*8]), .fw_in(wfw_out1[5 + i2*8]), .bw_in(wbw_out1[7 + i2*8]), .bw_out(wbw_out1[6 + i2*8]), .fw_out(wfw_out1[6 + i2*8]), .pulse((X == 6) && (Y == i2)), .r_out(R_OUT_D1[6 + i2*8]), .b_out(B_OUT_D1[6 + i2*8]) );
		move_cell m7(.r(R[7 + i2*8]), .b(B[7 + i2*8]), .fw_in(wfw_out1[6 + i2*8]), .bw_in(1'b0)                 , .bw_out(wbw_out1[7 + i2*8]), .fw_out(wfw_out1[7 + i2*8]), .pulse((X == 7) && (Y == i2)), .r_out(R_OUT_D1[7 + i2*8]), .b_out(B_OUT_D1[7 + i2*8]) );
	end	
endgenerate


/* Direction III : */
generate
genvar i3;
  for (i3 = 0; i3 < 8; i3=i3+1) begin:mcell2
		move_cell m0(.r(R[0*8 + i3]), .b(B[0*8 + i3]), .fw_in(1'b0),                  .bw_in(wbw_out2[1*8 + i3]), .bw_out(wbw_out2[0*8 + i3]), .fw_out(wfw_out2[0*8 + i3]),  .pulse((X == i3) && (Y == 0)), .r_out(R_OUT_D2[0*8 + i3]), .b_out(B_OUT_D2[0*8 + i3]) );
		move_cell m1(.r(R[1*8 + i3]), .b(B[1*8 + i3]), .fw_in(wfw_out2[0*8 + i3]), .bw_in(wbw_out2[2*8 + i3]), .bw_out(wbw_out2[1*8 + i3]), .fw_out(wfw_out2[1*8 + i3]),  .pulse((X == i3) && (Y == 1)), .r_out(R_OUT_D2[1*8 + i3]), .b_out(B_OUT_D2[1*8 + i3]) );
		move_cell m2(.r(R[2*8 + i3]), .b(B[2*8 + i3]), .fw_in(wfw_out2[1*8 + i3]), .bw_in(wbw_out2[3*8 + i3]), .bw_out(wbw_out2[2*8 + i3]), .fw_out(wfw_out2[2*8 + i3]),  .pulse((X == i3) && (Y == 2)), .r_out(R_OUT_D2[2*8 + i3]), .b_out(B_OUT_D2[2*8 + i3]) );
		move_cell m3(.r(R[3*8 + i3]), .b(B[3*8 + i3]), .fw_in(wfw_out2[2*8 + i3]), .bw_in(wbw_out2[4*8 + i3]), .bw_out(wbw_out2[3*8 + i3]), .fw_out(wfw_out2[3*8 + i3]),  .pulse((X == i3) && (Y == 3)), .r_out(R_OUT_D2[3*8 + i3]), .b_out(B_OUT_D2[3*8 + i3]) );
		move_cell m4(.r(R[4*8 + i3]), .b(B[4*8 + i3]), .fw_in(wfw_out2[3*8 + i3]), .bw_in(wbw_out2[5*8 + i3]), .bw_out(wbw_out2[4*8 + i3]), .fw_out(wfw_out2[4*8 + i3]),  .pulse((X == i3) && (Y == 4)), .r_out(R_OUT_D2[4*8 + i3]), .b_out(B_OUT_D2[4*8 + i3]) );
		move_cell m5(.r(R[5*8 + i3]), .b(B[5*8 + i3]), .fw_in(wfw_out2[4*8 + i3]), .bw_in(wbw_out2[6*8 + i3]), .bw_out(wbw_out2[5*8 + i3]), .fw_out(wfw_out2[5*8 + i3]),  .pulse((X == i3) && (Y == 5)), .r_out(R_OUT_D2[5*8 + i3]), .b_out(B_OUT_D2[5*8 + i3]) );
		move_cell m6(.r(R[6*8 + i3]), .b(B[6*8 + i3]), .fw_in(wfw_out2[5*8 + i3]), .bw_in(wbw_out2[7*8 + i3]), .bw_out(wbw_out2[6*8 + i3]), .fw_out(wfw_out2[6*8 + i3]),  .pulse((X == i3) && (Y == 6)), .r_out(R_OUT_D2[6*8 + i3]), .b_out(B_OUT_D2[6*8 + i3]) );
		move_cell m7(.r(R[7*8 + i3]), .b(B[7*8 + i3]), .fw_in(wfw_out2[6*8 + i3]), .bw_in(1'b0),                  .bw_out(wbw_out2[7*8 + i3]), .fw_out(wfw_out2[7*8 + i3]),  .pulse((X == i3) && (Y == 7)), .r_out(R_OUT_D2[7*8 + i3]), .b_out(B_OUT_D2[7*8 + i3]) );
	end	
endgenerate

/* Direction IV : */
generate
genvar i4;
  for (i4 = 0; i4 < 8; i4=i4+1) begin:mcell3
		move_cell m0(.r(R[0*8 + i4]), .b(B[0*8 + i4]), .fw_in(wfw_out3[1*8 + i4]), .bw_in(1'b0)                 , .bw_out(wbw_out3[0*8 + i4]), .fw_out(wfw_out3[0*8 + i4]),  .pulse((X == i4) && (Y == 0)), .r_out(R_OUT_D3[0*8 + i4]), .b_out(B_OUT_D3[0*8 + i4]) );
		move_cell m1(.r(R[1*8 + i4]), .b(B[1*8 + i4]), .fw_in(wfw_out3[2*8 + i4]), .bw_in(wbw_out3[0*8 + i4]), .bw_out(wbw_out3[1*8 + i4]), .fw_out(wfw_out3[1*8 + i4]),  .pulse((X == i4) && (Y == 1)), .r_out(R_OUT_D3[1*8 + i4]), .b_out(B_OUT_D3[1*8 + i4]) );
		move_cell m2(.r(R[2*8 + i4]), .b(B[2*8 + i4]), .fw_in(wfw_out3[3*8 + i4]), .bw_in(wbw_out3[1*8 + i4]), .bw_out(wbw_out3[2*8 + i4]), .fw_out(wfw_out3[2*8 + i4]),  .pulse((X == i4) && (Y == 2)), .r_out(R_OUT_D3[2*8 + i4]), .b_out(B_OUT_D3[2*8 + i4]) );
		move_cell m3(.r(R[3*8 + i4]), .b(B[3*8 + i4]), .fw_in(wfw_out3[4*8 + i4]), .bw_in(wbw_out3[2*8 + i4]), .bw_out(wbw_out3[3*8 + i4]), .fw_out(wfw_out3[3*8 + i4]),  .pulse((X == i4) && (Y == 3)), .r_out(R_OUT_D3[3*8 + i4]), .b_out(B_OUT_D3[3*8 + i4]) );
		move_cell m4(.r(R[4*8 + i4]), .b(B[4*8 + i4]), .fw_in(wfw_out3[5*8 + i4]), .bw_in(wbw_out3[3*8 + i4]), .bw_out(wbw_out3[4*8 + i4]), .fw_out(wfw_out3[4*8 + i4]),  .pulse((X == i4) && (Y == 4)), .r_out(R_OUT_D3[4*8 + i4]), .b_out(B_OUT_D3[4*8 + i4]) );
		move_cell m5(.r(R[5*8 + i4]), .b(B[5*8 + i4]), .fw_in(wfw_out3[6*8 + i4]), .bw_in(wbw_out3[4*8 + i4]), .bw_out(wbw_out3[5*8 + i4]), .fw_out(wfw_out3[5*8 + i4]),  .pulse((X == i4) && (Y == 5)), .r_out(R_OUT_D3[5*8 + i4]), .b_out(B_OUT_D3[5*8 + i4]) );
		move_cell m6(.r(R[6*8 + i4]), .b(B[6*8 + i4]), .fw_in(wfw_out3[7*8 + i4]), .bw_in(wbw_out3[5*8 + i4]), .bw_out(wbw_out3[6*8 + i4]), .fw_out(wfw_out3[6*8 + i4]),  .pulse((X == i4) && (Y == 6)), .r_out(R_OUT_D3[6*8 + i4]), .b_out(B_OUT_D3[6*8 + i4]) );
		move_cell m7(.r(R[7*8 + i4]), .b(B[7*8 + i4]), .fw_in(1'b0)                 , .bw_in(wbw_out3[6*8 + i4]), .bw_out(wbw_out3[7*8 + i4]), .fw_out(wfw_out3[7*8 + i4]),  .pulse((X == i4) && (Y == 7)), .r_out(R_OUT_D3[7*8 + i4]), .b_out(B_OUT_D3[7*8 + i4]) );
	end	
endgenerate
       
/* Direction V : */
generate
genvar i5;
  for (i5 = 0; i5 < 8; i5=i5+1) begin:mcell4
		if (i5 == 0) begin
				move_cell m0(.r(R[0*8 + i5]), .b(B[0*8 + i5]), .fw_in(1'b0)                         , .bw_in(1'b0), .bw_out(wbw_out4[(0+0)*8 + i5]), .fw_out(wfw_out4[(0+0)*8 + i5]),  .pulse((X == i5) && (Y == 0)), .r_out(R_OUT_D4[0*8 + i5]), .b_out(B_OUT_D4[0*8 + i5]) );
				move_cell m1(.r(R[1*8 + i5]), .b(B[1*8 + i5]), .fw_in(wfw_out4[(1-1)*8 + i5 + 1]), .bw_in(1'b0), .bw_out(wbw_out4[(0+1)*8 + i5]), .fw_out(wfw_out4[(0+1)*8 + i5]),  .pulse((X == i5) && (Y == 1)), .r_out(R_OUT_D4[1*8 + i5]), .b_out(B_OUT_D4[1*8 + i5]) );
				move_cell m2(.r(R[2*8 + i5]), .b(B[2*8 + i5]), .fw_in(wfw_out4[(2-1)*8 + i5 + 1]), .bw_in(1'b0), .bw_out(wbw_out4[(1+1)*8 + i5]), .fw_out(wfw_out4[(1+1)*8 + i5]),  .pulse((X == i5) && (Y == 2)), .r_out(R_OUT_D4[2*8 + i5]), .b_out(B_OUT_D4[2*8 + i5]) );
				move_cell m3(.r(R[3*8 + i5]), .b(B[3*8 + i5]), .fw_in(wfw_out4[(3-1)*8 + i5 + 1]), .bw_in(1'b0), .bw_out(wbw_out4[(2+1)*8 + i5]), .fw_out(wfw_out4[(2+1)*8 + i5]),  .pulse((X == i5) && (Y == 3)), .r_out(R_OUT_D4[3*8 + i5]), .b_out(B_OUT_D4[3*8 + i5]) );
				move_cell m4(.r(R[4*8 + i5]), .b(B[4*8 + i5]), .fw_in(wfw_out4[(4-1)*8 + i5 + 1]), .bw_in(1'b0), .bw_out(wbw_out4[(3+1)*8 + i5]), .fw_out(wfw_out4[(3+1)*8 + i5]),  .pulse((X == i5) && (Y == 4)), .r_out(R_OUT_D4[4*8 + i5]), .b_out(B_OUT_D4[4*8 + i5]) );
				move_cell m5(.r(R[5*8 + i5]), .b(B[5*8 + i5]), .fw_in(wfw_out4[(5-1)*8 + i5 + 1]), .bw_in(1'b0), .bw_out(wbw_out4[(4+1)*8 + i5]), .fw_out(wfw_out4[(4+1)*8 + i5]),  .pulse((X == i5) && (Y == 5)), .r_out(R_OUT_D4[5*8 + i5]), .b_out(B_OUT_D4[5*8 + i5]) );
				move_cell m6(.r(R[6*8 + i5]), .b(B[6*8 + i5]), .fw_in(wfw_out4[(6-1)*8 + i5 + 1]), .bw_in(1'b0), .bw_out(wbw_out4[(5+1)*8 + i5]), .fw_out(wfw_out4[(5+1)*8 + i5]),  .pulse((X == i5) && (Y == 6)), .r_out(R_OUT_D4[6*8 + i5]), .b_out(B_OUT_D4[6*8 + i5]) );
				move_cell m7(.r(R[7*8 + i5]), .b(B[7*8 + i5]), .fw_in(wfw_out4[(7-1)*8 + i5 + 1]), .bw_in(1'b0), .bw_out(wbw_out4[(6+1)*8 + i5]), .fw_out(wfw_out4[(6+1)*8 + i5]),  .pulse((X == i5) && (Y == 7)), .r_out(R_OUT_D4[7*8 + i5]), .b_out(B_OUT_D4[7*8 + i5]) );

		end
		else if ( i5 == 7 ) begin
			move_cell m0(.r(R[0*8 + i5]), .b(B[0*8 + i5]), .fw_in(1'b0), .bw_in(wbw_out4[(0+1)*8 + i5 - 1]), .bw_out(wbw_out4[(0+0)*8 + i5]), .fw_out(wfw_out4[(0+0)*8 + i5]),  .pulse((X == i5) && (Y == 0)), .r_out(R_OUT_D4[0*8 + i5]), .b_out(B_OUT_D4[0*8 + i5]) );
			move_cell m1(.r(R[1*8 + i5]), .b(B[1*8 + i5]), .fw_in(1'b0), .bw_in(wbw_out4[(1+1)*8 + i5 - 1]), .bw_out(wbw_out4[(0+1)*8 + i5]), .fw_out(wfw_out4[(0+1)*8 + i5]),  .pulse((X == i5) && (Y == 1)), .r_out(R_OUT_D4[1*8 + i5]), .b_out(B_OUT_D4[1*8 + i5]) );
			move_cell m2(.r(R[2*8 + i5]), .b(B[2*8 + i5]), .fw_in(1'b0), .bw_in(wbw_out4[(2+1)*8 + i5 - 1]), .bw_out(wbw_out4[(1+1)*8 + i5]), .fw_out(wfw_out4[(1+1)*8 + i5]),  .pulse((X == i5) && (Y == 2)), .r_out(R_OUT_D4[2*8 + i5]), .b_out(B_OUT_D4[2*8 + i5]) );
			move_cell m3(.r(R[3*8 + i5]), .b(B[3*8 + i5]), .fw_in(1'b0), .bw_in(wbw_out4[(3+1)*8 + i5 - 1]), .bw_out(wbw_out4[(2+1)*8 + i5]), .fw_out(wfw_out4[(2+1)*8 + i5]),  .pulse((X == i5) && (Y == 3)), .r_out(R_OUT_D4[3*8 + i5]), .b_out(B_OUT_D4[3*8 + i5]) );
			move_cell m4(.r(R[4*8 + i5]), .b(B[4*8 + i5]), .fw_in(1'b0), .bw_in(wbw_out4[(4+1)*8 + i5 - 1]), .bw_out(wbw_out4[(3+1)*8 + i5]), .fw_out(wfw_out4[(3+1)*8 + i5]),  .pulse((X == i5) && (Y == 4)), .r_out(R_OUT_D4[4*8 + i5]), .b_out(B_OUT_D4[4*8 + i5]) );
			move_cell m5(.r(R[5*8 + i5]), .b(B[5*8 + i5]), .fw_in(1'b0), .bw_in(wbw_out4[(5+1)*8 + i5 - 1]), .bw_out(wbw_out4[(4+1)*8 + i5]), .fw_out(wfw_out4[(4+1)*8 + i5]),  .pulse((X == i5) && (Y == 5)), .r_out(R_OUT_D4[5*8 + i5]), .b_out(B_OUT_D4[5*8 + i5]) );
			move_cell m6(.r(R[6*8 + i5]), .b(B[6*8 + i5]), .fw_in(1'b0), .bw_in(wbw_out4[(6+1)*8 + i5 - 1]), .bw_out(wbw_out4[(5+1)*8 + i5]), .fw_out(wfw_out4[(5+1)*8 + i5]),  .pulse((X == i5) && (Y == 6)), .r_out(R_OUT_D4[6*8 + i5]), .b_out(B_OUT_D4[6*8 + i5]) );
			move_cell m7(.r(R[7*8 + i5]), .b(B[7*8 + i5]), .fw_in(1'b0), .bw_in(1'b0)                         , .bw_out(wbw_out4[(6+1)*8 + i5]), .fw_out(wfw_out4[(6+1)*8 + i5]),  .pulse((X == i5) && (Y == 7)), .r_out(R_OUT_D4[7*8 + i5]), .b_out(B_OUT_D4[7*8 + i5]) );
		end
		else begin
			move_cell m0(.r(R[0*8 + i5]), .b(B[0*8 + i5]), .fw_in(1'b0)                         , .bw_in(wbw_out4[(0+1)*8 + i5 - 1]), .bw_out(wbw_out4[(0+0)*8 + i5]), .fw_out(wfw_out4[(0+0)*8 + i5]),  .pulse((X == i5) && (Y == 0)), .r_out(R_OUT_D4[0*8 + i5]), .b_out(B_OUT_D4[0*8 + i5]) );
			move_cell m1(.r(R[1*8 + i5]), .b(B[1*8 + i5]), .fw_in(wfw_out4[(1-1)*8 + i5 + 1]), .bw_in(wbw_out4[(1+1)*8 + i5 - 1]), .bw_out(wbw_out4[(0+1)*8 + i5]), .fw_out(wfw_out4[(0+1)*8 + i5]),  .pulse((X == i5) && (Y == 1)), .r_out(R_OUT_D4[1*8 + i5]), .b_out(B_OUT_D4[1*8 + i5]) );
			move_cell m2(.r(R[2*8 + i5]), .b(B[2*8 + i5]), .fw_in(wfw_out4[(2-1)*8 + i5 + 1]), .bw_in(wbw_out4[(2+1)*8 + i5 - 1]), .bw_out(wbw_out4[(1+1)*8 + i5]), .fw_out(wfw_out4[(1+1)*8 + i5]),  .pulse((X == i5) && (Y == 2)), .r_out(R_OUT_D4[2*8 + i5]), .b_out(B_OUT_D4[2*8 + i5]) );
			move_cell m3(.r(R[3*8 + i5]), .b(B[3*8 + i5]), .fw_in(wfw_out4[(3-1)*8 + i5 + 1]), .bw_in(wbw_out4[(3+1)*8 + i5 - 1]), .bw_out(wbw_out4[(2+1)*8 + i5]), .fw_out(wfw_out4[(2+1)*8 + i5]),  .pulse((X == i5) && (Y == 3)), .r_out(R_OUT_D4[3*8 + i5]), .b_out(B_OUT_D4[3*8 + i5]) );
			move_cell m4(.r(R[4*8 + i5]), .b(B[4*8 + i5]), .fw_in(wfw_out4[(4-1)*8 + i5 + 1]), .bw_in(wbw_out4[(4+1)*8 + i5 - 1]), .bw_out(wbw_out4[(3+1)*8 + i5]), .fw_out(wfw_out4[(3+1)*8 + i5]),  .pulse((X == i5) && (Y == 4)), .r_out(R_OUT_D4[4*8 + i5]), .b_out(B_OUT_D4[4*8 + i5]) );
			move_cell m5(.r(R[5*8 + i5]), .b(B[5*8 + i5]), .fw_in(wfw_out4[(5-1)*8 + i5 + 1]), .bw_in(wbw_out4[(5+1)*8 + i5 - 1]), .bw_out(wbw_out4[(4+1)*8 + i5]), .fw_out(wfw_out4[(4+1)*8 + i5]),  .pulse((X == i5) && (Y == 5)), .r_out(R_OUT_D4[5*8 + i5]), .b_out(B_OUT_D4[5*8 + i5]) );
			move_cell m6(.r(R[6*8 + i5]), .b(B[6*8 + i5]), .fw_in(wfw_out4[(6-1)*8 + i5 + 1]), .bw_in(wbw_out4[(6+1)*8 + i5 - 1]), .bw_out(wbw_out4[(5+1)*8 + i5]), .fw_out(wfw_out4[(5+1)*8 + i5]),  .pulse((X == i5) && (Y == 6)), .r_out(R_OUT_D4[6*8 + i5]), .b_out(B_OUT_D4[6*8 + i5]) );
			move_cell m7(.r(R[7*8 + i5]), .b(B[7*8 + i5]), .fw_in(wfw_out4[(7-1)*8 + i5 + 1]), .bw_in(1'b0)                         , .bw_out(wbw_out4[(6+1)*8 + i5]), .fw_out(wfw_out4[(6+1)*8 + i5]),  .pulse((X == i5) && (Y == 7)), .r_out(R_OUT_D4[7*8 + i5]), .b_out(B_OUT_D4[7*8 + i5]) );
		end	
	end	
endgenerate

/* Direction VI : */
generate
genvar i6;
  for (i6 = 0; i6 < 8; i6=i6+1) begin:mcell5
		if (i6 == 0) begin
				move_cell m0(.r(R[0*8 + i6]), .b(B[0*8 + i6]), .fw_in(1'b0), .bw_in(1'b0)                         , .bw_out(wbw_out5[(0+0)*8 + i6]), .fw_out(wfw_out5[(0+0)*8 + i6]),  .pulse((X == i6) && (Y == 0)), .r_out(R_OUT_D5[0*8 + i6]), .b_out(B_OUT_D5[0*8 + i6]) );
				move_cell m1(.r(R[1*8 + i6]), .b(B[1*8 + i6]), .fw_in(1'b0), .bw_in(wbw_out5[(1-1)*8 + i6 + 1]), .bw_out(wbw_out5[(0+1)*8 + i6]), .fw_out(wfw_out5[(0+1)*8 + i6]),  .pulse((X == i6) && (Y == 1)), .r_out(R_OUT_D5[1*8 + i6]), .b_out(B_OUT_D5[1*8 + i6]) );
				move_cell m2(.r(R[2*8 + i6]), .b(B[2*8 + i6]), .fw_in(1'b0), .bw_in(wbw_out5[(2-1)*8 + i6 + 1]), .bw_out(wbw_out5[(1+1)*8 + i6]), .fw_out(wfw_out5[(1+1)*8 + i6]),  .pulse((X == i6) && (Y == 2)), .r_out(R_OUT_D5[2*8 + i6]), .b_out(B_OUT_D5[2*8 + i6]) );
				move_cell m3(.r(R[3*8 + i6]), .b(B[3*8 + i6]), .fw_in(1'b0), .bw_in(wbw_out5[(3-1)*8 + i6 + 1]), .bw_out(wbw_out5[(2+1)*8 + i6]), .fw_out(wfw_out5[(2+1)*8 + i6]),  .pulse((X == i6) && (Y == 3)), .r_out(R_OUT_D5[3*8 + i6]), .b_out(B_OUT_D5[3*8 + i6]) );
				move_cell m4(.r(R[4*8 + i6]), .b(B[4*8 + i6]), .fw_in(1'b0), .bw_in(wbw_out5[(4-1)*8 + i6 + 1]), .bw_out(wbw_out5[(3+1)*8 + i6]), .fw_out(wfw_out5[(3+1)*8 + i6]),  .pulse((X == i6) && (Y == 4)), .r_out(R_OUT_D5[4*8 + i6]), .b_out(B_OUT_D5[4*8 + i6]) );
				move_cell m5(.r(R[5*8 + i6]), .b(B[5*8 + i6]), .fw_in(1'b0), .bw_in(wbw_out5[(5-1)*8 + i6 + 1]), .bw_out(wbw_out5[(4+1)*8 + i6]), .fw_out(wfw_out5[(4+1)*8 + i6]),  .pulse((X == i6) && (Y == 5)), .r_out(R_OUT_D5[5*8 + i6]), .b_out(B_OUT_D5[5*8 + i6]) );
				move_cell m6(.r(R[6*8 + i6]), .b(B[6*8 + i6]), .fw_in(1'b0), .bw_in(wbw_out5[(6-1)*8 + i6 + 1]), .bw_out(wbw_out5[(5+1)*8 + i6]), .fw_out(wfw_out5[(5+1)*8 + i6]),  .pulse((X == i6) && (Y == 6)), .r_out(R_OUT_D5[6*8 + i6]), .b_out(B_OUT_D5[6*8 + i6]) );
				move_cell m7(.r(R[7*8 + i6]), .b(B[7*8 + i6]), .fw_in(1'b0), .bw_in(wbw_out5[(7-1)*8 + i6 + 1]), .bw_out(wbw_out5[(6+1)*8 + i6]), .fw_out(wfw_out5[(6+1)*8 + i6]),  .pulse((X == i6) && (Y == 7)), .r_out(R_OUT_D5[7*8 + i6]), .b_out(B_OUT_D5[7*8 + i6]) );

		end
		else if ( i6 == 7 ) begin
			move_cell m0(.r(R[0*8 + i6]), .b(B[0*8 + i6]), .fw_in(wfw_out5[(0+1)*8 + i6 - 1]), .bw_in(1'b0), .bw_out(wbw_out5[(0+0)*8 + i6]), .fw_out(wfw_out5[(0+0)*8 + i6]),  .pulse((X == i6) && (Y == 0)), .r_out(R_OUT_D5[0*8 + i6]), .b_out(B_OUT_D5[0*8 + i6]) );
			move_cell m1(.r(R[1*8 + i6]), .b(B[1*8 + i6]), .fw_in(wfw_out5[(1+1)*8 + i6 - 1]), .bw_in(1'b0), .bw_out(wbw_out5[(0+1)*8 + i6]), .fw_out(wfw_out5[(0+1)*8 + i6]),  .pulse((X == i6) && (Y == 1)), .r_out(R_OUT_D5[1*8 + i6]), .b_out(B_OUT_D5[1*8 + i6]) );
			move_cell m2(.r(R[2*8 + i6]), .b(B[2*8 + i6]), .fw_in(wfw_out5[(2+1)*8 + i6 - 1]), .bw_in(1'b0), .bw_out(wbw_out5[(1+1)*8 + i6]), .fw_out(wfw_out5[(1+1)*8 + i6]),  .pulse((X == i6) && (Y == 2)), .r_out(R_OUT_D5[2*8 + i6]), .b_out(B_OUT_D5[2*8 + i6]) );
			move_cell m3(.r(R[3*8 + i6]), .b(B[3*8 + i6]), .fw_in(wfw_out5[(3+1)*8 + i6 - 1]), .bw_in(1'b0), .bw_out(wbw_out5[(2+1)*8 + i6]), .fw_out(wfw_out5[(2+1)*8 + i6]),  .pulse((X == i6) && (Y == 3)), .r_out(R_OUT_D5[3*8 + i6]), .b_out(B_OUT_D5[3*8 + i6]) );
			move_cell m4(.r(R[4*8 + i6]), .b(B[4*8 + i6]), .fw_in(wfw_out5[(4+1)*8 + i6 - 1]), .bw_in(1'b0), .bw_out(wbw_out5[(3+1)*8 + i6]), .fw_out(wfw_out5[(3+1)*8 + i6]),  .pulse((X == i6) && (Y == 4)), .r_out(R_OUT_D5[4*8 + i6]), .b_out(B_OUT_D5[4*8 + i6]) );
			move_cell m5(.r(R[5*8 + i6]), .b(B[5*8 + i6]), .fw_in(wfw_out5[(5+1)*8 + i6 - 1]), .bw_in(1'b0), .bw_out(wbw_out5[(4+1)*8 + i6]), .fw_out(wfw_out5[(4+1)*8 + i6]),  .pulse((X == i6) && (Y == 5)), .r_out(R_OUT_D5[5*8 + i6]), .b_out(B_OUT_D5[5*8 + i6]) );
			move_cell m6(.r(R[6*8 + i6]), .b(B[6*8 + i6]), .fw_in(wfw_out5[(6+1)*8 + i6 - 1]), .bw_in(1'b0), .bw_out(wbw_out5[(5+1)*8 + i6]), .fw_out(wfw_out5[(5+1)*8 + i6]),  .pulse((X == i6) && (Y == 6)), .r_out(R_OUT_D5[6*8 + i6]), .b_out(B_OUT_D5[6*8 + i6]) );
			move_cell m7(.r(R[7*8 + i6]), .b(B[7*8 + i6]), .fw_in(1'b0)                         , .bw_in(1'b0), .bw_out(wbw_out5[(6+1)*8 + i6]), .fw_out(wfw_out5[(6+1)*8 + i6]),  .pulse((X == i6) && (Y == 7)), .r_out(R_OUT_D5[7*8 + i6]), .b_out(B_OUT_D5[7*8 + i6]) );
		end
		else begin
			move_cell m0(.r(R[0*8 + i6]), .b(B[0*8 + i6]), .fw_in(wfw_out5[(0+1)*8 + i6 - 1]), .bw_in(1'b0)                         , .bw_out(wbw_out5[(0+0)*8 + i6]), .fw_out(wfw_out5[(0+0)*8 + i6]),  .pulse((X == i6) && (Y == 0)), .r_out(R_OUT_D5[0*8 + i6]), .b_out(B_OUT_D5[0*8 + i6]) );
			move_cell m1(.r(R[1*8 + i6]), .b(B[1*8 + i6]), .fw_in(wfw_out5[(1+1)*8 + i6 - 1]), .bw_in(wbw_out5[(1-1)*8 + i6 + 1]), .bw_out(wbw_out5[(0+1)*8 + i6]), .fw_out(wfw_out5[(0+1)*8 + i6]),  .pulse((X == i6) && (Y == 1)), .r_out(R_OUT_D5[1*8 + i6]), .b_out(B_OUT_D5[1*8 + i6]) );
			move_cell m2(.r(R[2*8 + i6]), .b(B[2*8 + i6]), .fw_in(wfw_out5[(2+1)*8 + i6 - 1]), .bw_in(wbw_out5[(2-1)*8 + i6 + 1]), .bw_out(wbw_out5[(1+1)*8 + i6]), .fw_out(wfw_out5[(1+1)*8 + i6]),  .pulse((X == i6) && (Y == 2)), .r_out(R_OUT_D5[2*8 + i6]), .b_out(B_OUT_D5[2*8 + i6]) );
			move_cell m3(.r(R[3*8 + i6]), .b(B[3*8 + i6]), .fw_in(wfw_out5[(3+1)*8 + i6 - 1]), .bw_in(wbw_out5[(3-1)*8 + i6 + 1]), .bw_out(wbw_out5[(2+1)*8 + i6]), .fw_out(wfw_out5[(2+1)*8 + i6]),  .pulse((X == i6) && (Y == 3)), .r_out(R_OUT_D5[3*8 + i6]), .b_out(B_OUT_D5[3*8 + i6]) );
			move_cell m4(.r(R[4*8 + i6]), .b(B[4*8 + i6]), .fw_in(wfw_out5[(4+1)*8 + i6 - 1]), .bw_in(wbw_out5[(4-1)*8 + i6 + 1]), .bw_out(wbw_out5[(3+1)*8 + i6]), .fw_out(wfw_out5[(3+1)*8 + i6]),  .pulse((X == i6) && (Y == 4)), .r_out(R_OUT_D5[4*8 + i6]), .b_out(B_OUT_D5[4*8 + i6]) );
			move_cell m5(.r(R[5*8 + i6]), .b(B[5*8 + i6]), .fw_in(wfw_out5[(5+1)*8 + i6 - 1]), .bw_in(wbw_out5[(5-1)*8 + i6 + 1]), .bw_out(wbw_out5[(4+1)*8 + i6]), .fw_out(wfw_out5[(4+1)*8 + i6]),  .pulse((X == i6) && (Y == 5)), .r_out(R_OUT_D5[5*8 + i6]), .b_out(B_OUT_D5[5*8 + i6]) );
			move_cell m6(.r(R[6*8 + i6]), .b(B[6*8 + i6]), .fw_in(wfw_out5[(6+1)*8 + i6 - 1]), .bw_in(wbw_out5[(6-1)*8 + i6 + 1]), .bw_out(wbw_out5[(5+1)*8 + i6]), .fw_out(wfw_out5[(5+1)*8 + i6]),  .pulse((X == i6) && (Y == 6)), .r_out(R_OUT_D5[6*8 + i6]), .b_out(B_OUT_D5[6*8 + i6]) );
			move_cell m7(.r(R[7*8 + i6]), .b(B[7*8 + i6]), .fw_in(1'b0)                         , .bw_in(wbw_out5[(7-1)*8 + i6 + 1]), .bw_out(wbw_out5[(6+1)*8 + i6]), .fw_out(wfw_out5[(6+1)*8 + i6]),  .pulse((X == i6) && (Y == 7)), .r_out(R_OUT_D5[7*8 + i6]), .b_out(B_OUT_D5[7*8 + i6]) );
		end	
	end	
endgenerate

/* Direction VII : */
generate
genvar i7;
  for (i7 = 0; i7 < 8; i7=i7+1) begin:mcell6
		if (i7 == 0) begin
				move_cell m0(.r(R[0*8 + i7]), .b(B[0*8 + i7]), .fw_in(wfw_out6[(0+1)*8 + i7 + 1]), .bw_in(1'b0), .bw_out(wbw_out6[(0+0)*8 + i7]), .fw_out(wfw_out6[(0+0)*8 + i7]),  .pulse((X == i7) && (Y == 0)), .r_out(R_OUT_D6[0*8 + i7]), .b_out(B_OUT_D6[0*8 + i7]) );
				move_cell m1(.r(R[1*8 + i7]), .b(B[1*8 + i7]), .fw_in(wfw_out6[(1+1)*8 + i7 + 1]), .bw_in(1'b0), .bw_out(wbw_out6[(0+1)*8 + i7]), .fw_out(wfw_out6[(0+1)*8 + i7]),  .pulse((X == i7) && (Y == 1)), .r_out(R_OUT_D6[1*8 + i7]), .b_out(B_OUT_D6[1*8 + i7]) );
				move_cell m2(.r(R[2*8 + i7]), .b(B[2*8 + i7]), .fw_in(wfw_out6[(2+1)*8 + i7 + 1]), .bw_in(1'b0), .bw_out(wbw_out6[(1+1)*8 + i7]), .fw_out(wfw_out6[(1+1)*8 + i7]),  .pulse((X == i7) && (Y == 2)), .r_out(R_OUT_D6[2*8 + i7]), .b_out(B_OUT_D6[2*8 + i7]) );
				move_cell m3(.r(R[3*8 + i7]), .b(B[3*8 + i7]), .fw_in(wfw_out6[(3+1)*8 + i7 + 1]), .bw_in(1'b0), .bw_out(wbw_out6[(2+1)*8 + i7]), .fw_out(wfw_out6[(2+1)*8 + i7]),  .pulse((X == i7) && (Y == 3)), .r_out(R_OUT_D6[3*8 + i7]), .b_out(B_OUT_D6[3*8 + i7]) );
				move_cell m4(.r(R[4*8 + i7]), .b(B[4*8 + i7]), .fw_in(wfw_out6[(4+1)*8 + i7 + 1]), .bw_in(1'b0), .bw_out(wbw_out6[(3+1)*8 + i7]), .fw_out(wfw_out6[(3+1)*8 + i7]),  .pulse((X == i7) && (Y == 4)), .r_out(R_OUT_D6[4*8 + i7]), .b_out(B_OUT_D6[4*8 + i7]) );
				move_cell m5(.r(R[5*8 + i7]), .b(B[5*8 + i7]), .fw_in(wfw_out6[(5+1)*8 + i7 + 1]), .bw_in(1'b0), .bw_out(wbw_out6[(4+1)*8 + i7]), .fw_out(wfw_out6[(4+1)*8 + i7]),  .pulse((X == i7) && (Y == 5)), .r_out(R_OUT_D6[5*8 + i7]), .b_out(B_OUT_D6[5*8 + i7]) );
				move_cell m6(.r(R[6*8 + i7]), .b(B[6*8 + i7]), .fw_in(wfw_out6[(6+1)*8 + i7 + 1]), .bw_in(1'b0), .bw_out(wbw_out6[(5+1)*8 + i7]), .fw_out(wfw_out6[(5+1)*8 + i7]),  .pulse((X == i7) && (Y == 6)), .r_out(R_OUT_D6[6*8 + i7]), .b_out(B_OUT_D6[6*8 + i7]) );
				move_cell m7(.r(R[7*8 + i7]), .b(B[7*8 + i7]), .fw_in(1'b0)                         , .bw_in(1'b0), .bw_out(wbw_out6[(6+1)*8 + i7]), .fw_out(wfw_out6[(6+1)*8 + i7]),  .pulse((X == i7) && (Y == 7)), .r_out(R_OUT_D6[7*8 + i7]), .b_out(B_OUT_D6[7*8 + i7]) );

		end
		else if ( i7 == 7 ) begin
			move_cell m0(.r(R[0*8 + i7]), .b(B[0*8 + i7]), .fw_in(1'b0), .bw_in(1'b0)                         , .bw_out(wbw_out6[(0+0)*8 + i7]), .fw_out(wfw_out6[(0+0)*8 + i7]),  .pulse((X == i7) && (Y == 0)), .r_out(R_OUT_D6[0*8 + i7]), .b_out(B_OUT_D6[0*8 + i7]) );
			move_cell m1(.r(R[1*8 + i7]), .b(B[1*8 + i7]), .fw_in(1'b0), .bw_in(wbw_out6[(1-1)*8 + i7 - 1]), .bw_out(wbw_out6[(0+1)*8 + i7]), .fw_out(wfw_out6[(0+1)*8 + i7]),  .pulse((X == i7) && (Y == 1)), .r_out(R_OUT_D6[1*8 + i7]), .b_out(B_OUT_D6[1*8 + i7]) );
			move_cell m2(.r(R[2*8 + i7]), .b(B[2*8 + i7]), .fw_in(1'b0), .bw_in(wbw_out6[(2-1)*8 + i7 - 1]), .bw_out(wbw_out6[(1+1)*8 + i7]), .fw_out(wfw_out6[(1+1)*8 + i7]),  .pulse((X == i7) && (Y == 2)), .r_out(R_OUT_D6[2*8 + i7]), .b_out(B_OUT_D6[2*8 + i7]) );
			move_cell m3(.r(R[3*8 + i7]), .b(B[3*8 + i7]), .fw_in(1'b0), .bw_in(wbw_out6[(3-1)*8 + i7 - 1]), .bw_out(wbw_out6[(2+1)*8 + i7]), .fw_out(wfw_out6[(2+1)*8 + i7]),  .pulse((X == i7) && (Y == 3)), .r_out(R_OUT_D6[3*8 + i7]), .b_out(B_OUT_D6[3*8 + i7]) );
			move_cell m4(.r(R[4*8 + i7]), .b(B[4*8 + i7]), .fw_in(1'b0), .bw_in(wbw_out6[(4-1)*8 + i7 - 1]), .bw_out(wbw_out6[(3+1)*8 + i7]), .fw_out(wfw_out6[(3+1)*8 + i7]),  .pulse((X == i7) && (Y == 4)), .r_out(R_OUT_D6[4*8 + i7]), .b_out(B_OUT_D6[4*8 + i7]) );
			move_cell m5(.r(R[5*8 + i7]), .b(B[5*8 + i7]), .fw_in(1'b0), .bw_in(wbw_out6[(5-1)*8 + i7 - 1]), .bw_out(wbw_out6[(4+1)*8 + i7]), .fw_out(wfw_out6[(4+1)*8 + i7]),  .pulse((X == i7) && (Y == 5)), .r_out(R_OUT_D6[5*8 + i7]), .b_out(B_OUT_D6[5*8 + i7]) );
			move_cell m6(.r(R[6*8 + i7]), .b(B[6*8 + i7]), .fw_in(1'b0), .bw_in(wbw_out6[(6-1)*8 + i7 - 1]), .bw_out(wbw_out6[(5+1)*8 + i7]), .fw_out(wfw_out6[(5+1)*8 + i7]),  .pulse((X == i7) && (Y == 6)), .r_out(R_OUT_D6[6*8 + i7]), .b_out(B_OUT_D6[6*8 + i7]) );
			move_cell m7(.r(R[7*8 + i7]), .b(B[7*8 + i7]), .fw_in(1'b0), .bw_in(wbw_out6[(7-1)*8 + i7 - 1]), .bw_out(wbw_out6[(6+1)*8 + i7]), .fw_out(wfw_out6[(6+1)*8 + i7]),  .pulse((X == i7) && (Y == 7)), .r_out(R_OUT_D6[7*8 + i7]), .b_out(B_OUT_D6[7*8 + i7]) );
		end
		else begin
			move_cell m0(.r(R[0*8 + i7]), .b(B[0*8 + i7]), .fw_in(wfw_out6[(0+1)*8 + i7 + 1]), .bw_in(1'b0)                         , .bw_out(wbw_out6[(0+0)*8 + i7]), .fw_out(wfw_out6[(0+0)*8 + i7]),  .pulse((X == i7) && (Y == 0)), .r_out(R_OUT_D6[0*8 + i7]), .b_out(B_OUT_D6[0*8 + i7]) );
			move_cell m1(.r(R[1*8 + i7]), .b(B[1*8 + i7]), .fw_in(wfw_out6[(1+1)*8 + i7 + 1]), .bw_in(wbw_out6[(1-1)*8 + i7 - 1]), .bw_out(wbw_out6[(0+1)*8 + i7]), .fw_out(wfw_out6[(0+1)*8 + i7]),  .pulse((X == i7) && (Y == 1)), .r_out(R_OUT_D6[1*8 + i7]), .b_out(B_OUT_D6[1*8 + i7]) );
			move_cell m2(.r(R[2*8 + i7]), .b(B[2*8 + i7]), .fw_in(wfw_out6[(2+1)*8 + i7 + 1]), .bw_in(wbw_out6[(2-1)*8 + i7 - 1]), .bw_out(wbw_out6[(1+1)*8 + i7]), .fw_out(wfw_out6[(1+1)*8 + i7]),  .pulse((X == i7) && (Y == 2)), .r_out(R_OUT_D6[2*8 + i7]), .b_out(B_OUT_D6[2*8 + i7]) );
			move_cell m3(.r(R[3*8 + i7]), .b(B[3*8 + i7]), .fw_in(wfw_out6[(3+1)*8 + i7 + 1]), .bw_in(wbw_out6[(3-1)*8 + i7 - 1]), .bw_out(wbw_out6[(2+1)*8 + i7]), .fw_out(wfw_out6[(2+1)*8 + i7]),  .pulse((X == i7) && (Y == 3)), .r_out(R_OUT_D6[3*8 + i7]), .b_out(B_OUT_D6[3*8 + i7]) );
			move_cell m4(.r(R[4*8 + i7]), .b(B[4*8 + i7]), .fw_in(wfw_out6[(4+1)*8 + i7 + 1]), .bw_in(wbw_out6[(4-1)*8 + i7 - 1]), .bw_out(wbw_out6[(3+1)*8 + i7]), .fw_out(wfw_out6[(3+1)*8 + i7]),  .pulse((X == i7) && (Y == 4)), .r_out(R_OUT_D6[4*8 + i7]), .b_out(B_OUT_D6[4*8 + i7]) );
			move_cell m5(.r(R[5*8 + i7]), .b(B[5*8 + i7]), .fw_in(wfw_out6[(5+1)*8 + i7 + 1]), .bw_in(wbw_out6[(5-1)*8 + i7 - 1]), .bw_out(wbw_out6[(4+1)*8 + i7]), .fw_out(wfw_out6[(4+1)*8 + i7]),  .pulse((X == i7) && (Y == 5)), .r_out(R_OUT_D6[5*8 + i7]), .b_out(B_OUT_D6[5*8 + i7]) );
			move_cell m6(.r(R[6*8 + i7]), .b(B[6*8 + i7]), .fw_in(wfw_out6[(6+1)*8 + i7 + 1]), .bw_in(wbw_out6[(6-1)*8 + i7 - 1]), .bw_out(wbw_out6[(5+1)*8 + i7]), .fw_out(wfw_out6[(5+1)*8 + i7]),  .pulse((X == i7) && (Y == 6)), .r_out(R_OUT_D6[6*8 + i7]), .b_out(B_OUT_D6[6*8 + i7]) );
			move_cell m7(.r(R[7*8 + i7]), .b(B[7*8 + i7]), .fw_in(1'b0)                         , .bw_in(wbw_out6[(7-1)*8 + i7 - 1]), .bw_out(wbw_out6[(6+1)*8 + i7]), .fw_out(wfw_out6[(6+1)*8 + i7]),  .pulse((X == i7) && (Y == 7)), .r_out(R_OUT_D6[7*8 + i7]), .b_out(B_OUT_D6[7*8 + i7]) );
		end	
	end	
endgenerate

/* Direction VIII : */
generate
genvar i8;
  for (i8 = 0; i8 < 8; i8=i8+1) begin:mcell7
		if (i8 == 0) begin
			move_cell m0(.r(R[0*8 + i8]), .b(B[0*8 + i8]), .fw_in(1'b0), .bw_in(wbw_out7[(0+1)*8 + i8 + 1]), .bw_out(wbw_out7[(0+0)*8 + i8]), .fw_out(wfw_out7[(0+0)*8 + i8]),  .pulse((X == i8) && (Y == 0)), .r_out(R_OUT_D7[0*8 + i8]), .b_out(B_OUT_D7[0*8 + i8]) );
			move_cell m1(.r(R[1*8 + i8]), .b(B[1*8 + i8]), .fw_in(1'b0), .bw_in(wbw_out7[(1+1)*8 + i8 + 1]), .bw_out(wbw_out7[(0+1)*8 + i8]), .fw_out(wfw_out7[(0+1)*8 + i8]),  .pulse((X == i8) && (Y == 1)), .r_out(R_OUT_D7[1*8 + i8]), .b_out(B_OUT_D7[1*8 + i8]) );
			move_cell m2(.r(R[2*8 + i8]), .b(B[2*8 + i8]), .fw_in(1'b0), .bw_in(wbw_out7[(2+1)*8 + i8 + 1]), .bw_out(wbw_out7[(1+1)*8 + i8]), .fw_out(wfw_out7[(1+1)*8 + i8]),  .pulse((X == i8) && (Y == 2)), .r_out(R_OUT_D7[2*8 + i8]), .b_out(B_OUT_D7[2*8 + i8]) );
			move_cell m3(.r(R[3*8 + i8]), .b(B[3*8 + i8]), .fw_in(1'b0), .bw_in(wbw_out7[(3+1)*8 + i8 + 1]), .bw_out(wbw_out7[(2+1)*8 + i8]), .fw_out(wfw_out7[(2+1)*8 + i8]),  .pulse((X == i8) && (Y == 3)), .r_out(R_OUT_D7[3*8 + i8]), .b_out(B_OUT_D7[3*8 + i8]) );
			move_cell m4(.r(R[4*8 + i8]), .b(B[4*8 + i8]), .fw_in(1'b0), .bw_in(wbw_out7[(4+1)*8 + i8 + 1]), .bw_out(wbw_out7[(3+1)*8 + i8]), .fw_out(wfw_out7[(3+1)*8 + i8]),  .pulse((X == i8) && (Y == 4)), .r_out(R_OUT_D7[4*8 + i8]), .b_out(B_OUT_D7[4*8 + i8]) );
			move_cell m5(.r(R[5*8 + i8]), .b(B[5*8 + i8]), .fw_in(1'b0), .bw_in(wbw_out7[(5+1)*8 + i8 + 1]), .bw_out(wbw_out7[(4+1)*8 + i8]), .fw_out(wfw_out7[(4+1)*8 + i8]),  .pulse((X == i8) && (Y == 5)), .r_out(R_OUT_D7[5*8 + i8]), .b_out(B_OUT_D7[5*8 + i8]) );
			move_cell m6(.r(R[6*8 + i8]), .b(B[6*8 + i8]), .fw_in(1'b0), .bw_in(wbw_out7[(6+1)*8 + i8 + 1]), .bw_out(wbw_out7[(5+1)*8 + i8]), .fw_out(wfw_out7[(5+1)*8 + i8]),  .pulse((X == i8) && (Y == 6)), .r_out(R_OUT_D7[6*8 + i8]), .b_out(B_OUT_D7[6*8 + i8]) );
			move_cell m7(.r(R[7*8 + i8]), .b(B[7*8 + i8]), .fw_in(1'b0), .bw_in(1'b0)                         , .bw_out(wbw_out7[(6+1)*8 + i8]), .fw_out(wfw_out7[(6+1)*8 + i8]),  .pulse((X == i8) && (Y == 7)), .r_out(R_OUT_D7[7*8 + i8]), .b_out(B_OUT_D7[7*8 + i8]) );
		end
		else if ( i8 == 7 ) begin
			move_cell m0(.r(R[0*8 + i8]), .b(B[0*8 + i8]), .fw_in(1'b0)                         , .bw_in(1'b0), .bw_out(wbw_out7[(0+0)*8 + i8]), .fw_out(wfw_out7[(0+0)*8 + i8]),  .pulse((X == i8) && (Y == 0)), .r_out(R_OUT_D7[0*8 + i8]), .b_out(B_OUT_D7[0*8 + i8]) );
			move_cell m1(.r(R[1*8 + i8]), .b(B[1*8 + i8]), .fw_in(wfw_out7[(0+0)*8 + i8 - 1]), .bw_in(1'b0), .bw_out(wbw_out7[(0+1)*8 + i8]), .fw_out(wfw_out7[(0+1)*8 + i8]),  .pulse((X == i8) && (Y == 1)), .r_out(R_OUT_D7[1*8 + i8]), .b_out(B_OUT_D7[1*8 + i8]) );
			move_cell m2(.r(R[2*8 + i8]), .b(B[2*8 + i8]), .fw_in(wfw_out7[(0+1)*8 + i8 - 1]), .bw_in(1'b0), .bw_out(wbw_out7[(1+1)*8 + i8]), .fw_out(wfw_out7[(1+1)*8 + i8]),  .pulse((X == i8) && (Y == 2)), .r_out(R_OUT_D7[2*8 + i8]), .b_out(B_OUT_D7[2*8 + i8]) );
			move_cell m3(.r(R[3*8 + i8]), .b(B[3*8 + i8]), .fw_in(wfw_out7[(1+1)*8 + i8 - 1]), .bw_in(1'b0), .bw_out(wbw_out7[(2+1)*8 + i8]), .fw_out(wfw_out7[(2+1)*8 + i8]),  .pulse((X == i8) && (Y == 3)), .r_out(R_OUT_D7[3*8 + i8]), .b_out(B_OUT_D7[3*8 + i8]) );
			move_cell m4(.r(R[4*8 + i8]), .b(B[4*8 + i8]), .fw_in(wfw_out7[(2+1)*8 + i8 - 1]), .bw_in(1'b0), .bw_out(wbw_out7[(3+1)*8 + i8]), .fw_out(wfw_out7[(3+1)*8 + i8]),  .pulse((X == i8) && (Y == 4)), .r_out(R_OUT_D7[4*8 + i8]), .b_out(B_OUT_D7[4*8 + i8]) );
			move_cell m5(.r(R[5*8 + i8]), .b(B[5*8 + i8]), .fw_in(wfw_out7[(3+1)*8 + i8 - 1]), .bw_in(1'b0), .bw_out(wbw_out7[(4+1)*8 + i8]), .fw_out(wfw_out7[(4+1)*8 + i8]),  .pulse((X == i8) && (Y == 5)), .r_out(R_OUT_D7[5*8 + i8]), .b_out(B_OUT_D7[5*8 + i8]) );
			move_cell m6(.r(R[6*8 + i8]), .b(B[6*8 + i8]), .fw_in(wfw_out7[(4+1)*8 + i8 - 1]), .bw_in(1'b0), .bw_out(wbw_out7[(5+1)*8 + i8]), .fw_out(wfw_out7[(5+1)*8 + i8]),  .pulse((X == i8) && (Y == 6)), .r_out(R_OUT_D7[6*8 + i8]), .b_out(B_OUT_D7[6*8 + i8]) );
			move_cell m7(.r(R[7*8 + i8]), .b(B[7*8 + i8]), .fw_in(wfw_out7[(5+1)*8 + i8 - 1]), .bw_in(1'b0), .bw_out(wbw_out7[(6+1)*8 + i8]), .fw_out(wfw_out7[(6+1)*8 + i8]),  .pulse((X == i8) && (Y == 7)), .r_out(R_OUT_D7[7*8 + i8]), .b_out(B_OUT_D7[7*8 + i8]) );
		end
		else begin
			move_cell m0(.r(R[0*8 + i8]), .b(B[0*8 + i8]), .fw_in(1'b0)                         , .bw_in(wbw_out7[(0+1)*8 + i8 + 1]), .bw_out(wbw_out7[(0+0)*8 + i8]), .fw_out(wfw_out7[(0+0)*8 + i8]),  .pulse((X == i8) && (Y == 0)), .r_out(R_OUT_D7[0*8 + i8]), .b_out(B_OUT_D7[0*8 + i8]) );
			move_cell m1(.r(R[1*8 + i8]), .b(B[1*8 + i8]), .fw_in(wfw_out7[(0+0)*8 + i8 - 1]), .bw_in(wbw_out7[(1+1)*8 + i8 + 1]), .bw_out(wbw_out7[(0+1)*8 + i8]), .fw_out(wfw_out7[(0+1)*8 + i8]),  .pulse((X == i8) && (Y == 1)), .r_out(R_OUT_D7[1*8 + i8]), .b_out(B_OUT_D7[1*8 + i8]) );
			move_cell m2(.r(R[2*8 + i8]), .b(B[2*8 + i8]), .fw_in(wfw_out7[(0+1)*8 + i8 - 1]), .bw_in(wbw_out7[(2+1)*8 + i8 + 1]), .bw_out(wbw_out7[(1+1)*8 + i8]), .fw_out(wfw_out7[(1+1)*8 + i8]),  .pulse((X == i8) && (Y == 2)), .r_out(R_OUT_D7[2*8 + i8]), .b_out(B_OUT_D7[2*8 + i8]) );
			move_cell m3(.r(R[3*8 + i8]), .b(B[3*8 + i8]), .fw_in(wfw_out7[(1+1)*8 + i8 - 1]), .bw_in(wbw_out7[(3+1)*8 + i8 + 1]), .bw_out(wbw_out7[(2+1)*8 + i8]), .fw_out(wfw_out7[(2+1)*8 + i8]),  .pulse((X == i8) && (Y == 3)), .r_out(R_OUT_D7[3*8 + i8]), .b_out(B_OUT_D7[3*8 + i8]) );
			move_cell m4(.r(R[4*8 + i8]), .b(B[4*8 + i8]), .fw_in(wfw_out7[(2+1)*8 + i8 - 1]), .bw_in(wbw_out7[(4+1)*8 + i8 + 1]), .bw_out(wbw_out7[(3+1)*8 + i8]), .fw_out(wfw_out7[(3+1)*8 + i8]),  .pulse((X == i8) && (Y == 4)), .r_out(R_OUT_D7[4*8 + i8]), .b_out(B_OUT_D7[4*8 + i8]) );
			move_cell m5(.r(R[5*8 + i8]), .b(B[5*8 + i8]), .fw_in(wfw_out7[(3+1)*8 + i8 - 1]), .bw_in(wbw_out7[(5+1)*8 + i8 + 1]), .bw_out(wbw_out7[(4+1)*8 + i8]), .fw_out(wfw_out7[(4+1)*8 + i8]),  .pulse((X == i8) && (Y == 5)), .r_out(R_OUT_D7[5*8 + i8]), .b_out(B_OUT_D7[5*8 + i8]) );
			move_cell m6(.r(R[6*8 + i8]), .b(B[6*8 + i8]), .fw_in(wfw_out7[(4+1)*8 + i8 - 1]), .bw_in(wbw_out7[(6+1)*8 + i8 + 1]), .bw_out(wbw_out7[(5+1)*8 + i8]), .fw_out(wfw_out7[(5+1)*8 + i8]),  .pulse((X == i8) && (Y == 6)), .r_out(R_OUT_D7[6*8 + i8]), .b_out(B_OUT_D7[6*8 + i8]) );
			move_cell m7(.r(R[7*8 + i8]), .b(B[7*8 + i8]), .fw_in(wfw_out7[(5+1)*8 + i8 - 1]), .bw_in(1'b0)                         , .bw_out(wbw_out7[(6+1)*8 + i8]), .fw_out(wfw_out7[(6+1)*8 + i8]),  .pulse((X == i8) && (Y == 7)), .r_out(R_OUT_D7[7*8 + i8]), .b_out(B_OUT_D7[7*8 + i8]) );
		end	
	end	
endgenerate

always @( * ) begin

	if ( player ) begin
		R_OUT_D = B_OUT_D0 | B_OUT_D1 | B_OUT_D2 | B_OUT_D3 | B_OUT_D4 | B_OUT_D5 | B_OUT_D6 | B_OUT_D7;
		B_OUT_D = R_OUT_D0 & R_OUT_D1 & R_OUT_D2 & R_OUT_D3 & R_OUT_D4 & R_OUT_D5 & R_OUT_D6 & R_OUT_D7;
		R_OUT_D[Y*8 + X] = 1;
		B_OUT_D[Y*8 + X] = 0;
	end
	else begin
		R_OUT_D = R_OUT_D0 & R_OUT_D1 & R_OUT_D2 & R_OUT_D3 & R_OUT_D4 & R_OUT_D5 & R_OUT_D6 & R_OUT_D7;
		B_OUT_D = B_OUT_D0 | B_OUT_D1 | B_OUT_D2 | B_OUT_D3 | B_OUT_D4 | B_OUT_D5 | B_OUT_D6 | B_OUT_D7;
		R_OUT_D[Y*8 + X] = 0;
		B_OUT_D[Y*8 + X] = 1;

	end
end

/* continuous assignment, inputs are function of player */
assign R = (player) ? B_ : R_;
assign B = (player) ? R_ : B_;

/* secvential logic */
always  @(posedge clk) begin
   if (RST) begin
		/* prepare outputs */
		R_OUT_Q <= R_;
		B_OUT_Q <= B_;
	end 
	else begin
		/* output logic, registered, depends of player */
		R_OUT_Q <= R_OUT_D;
		B_OUT_Q <= B_OUT_D;
		/*
		if ( player ) begin
			R_OUT_Q <= B_OUT_D0 | B_OUT_D1 | B_OUT_D2 | B_OUT_D3 | B_OUT_D4 | B_OUT_D5 | B_OUT_D6 | B_OUT_D7;
			B_OUT_Q <= R_OUT_D0 & R_OUT_D1 & R_OUT_D2 & R_OUT_D3 & R_OUT_D4 & R_OUT_D5 & R_OUT_D6 & R_OUT_D7;
		end
		else begin
			R_OUT_Q <= R_OUT_D0 & R_OUT_D1 & R_OUT_D2 & R_OUT_D3 & R_OUT_D4 & R_OUT_D5 & R_OUT_D6 & R_OUT_D7;
			B_OUT_Q <= B_OUT_D0 | B_OUT_D1 | B_OUT_D2 | B_OUT_D3 | B_OUT_D4 | B_OUT_D5 | B_OUT_D6 | B_OUT_D7;
		end
		*/
	end
end


assign R_OUT = R_OUT_Q;
assign B_OUT = B_OUT_Q;

endmodule
