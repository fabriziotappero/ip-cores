`timescale 1ns / 1ps
`include "aDefinitions.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:49:14 01/13/2009 
// Design Name: 
// Module Name:    RadixRMul 
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

`default_nettype none


//---------------------------------------------------
module MUX_4_TO_1_32Bits_FullParallel
(
	input wire [31:0] i1,i2,i3,i4,
	output reg [31:0] O,
	input wire [1:0] Sel
);

always @ ( Sel or i1 or i2 or i3 or i4 )
begin
	case (Sel)
		2'b00: O = i1;
		2'b01: O = i2;
		2'b10: O = i3;
		2'b11: O = i4;
	endcase
	
end

endmodule
//---------------------------------------------------
/*
module SHIFTER2_16_BITS
(
input wire C,
input wire[15:0] In,
output reg[15:0] Out
);

reg [15:0] Temp;
always @ (posedge C )
begin
	Out =  In << 2;
	
end

endmodule
*/
//---------------------------------------------------
module RADIX_R_MUL_32_FULL_PARALLEL
(
	input wire Clock,
	input wire Reset,
	input wire[31:0] A,
	input wire[31:0] B,
	output wire[63:0] R,
	input wire iUnscaled,
	input wire iInputReady,
	output wire OutputReady

	
);


wire wInputDelay1;
//-------------------
wire [31:0] wALatched,wBLatched;
FFD_POSEDGE_SYNCRONOUS_RESET # ( `WIDTH ) FFD1
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( iInputReady ),
	.D( A ),
	.Q( wALatched)
);
FFD_POSEDGE_SYNCRONOUS_RESET # ( `WIDTH ) FFD2
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( iInputReady ),
	.D( B ),
	.Q( wBLatched )
);

//-------------------


FFD_POSEDGE_ASYNC_RESET #(1) FFOutputReadyDelay1
(
	.Clock( Clock ),
	.Clear( Reset ),
	.D( iInputReady ),
	.Q( wInputDelay1 )
);

FFD_POSEDGE_ASYNC_RESET #(1) FFOutputReadyDelay2
(
	.Clock( Clock ),
	.Clear( Reset ),
	.D(  wInputDelay1 ),
	.Q( OutputReady  )
);

wire [31:0] wA, w2A, w3A, wB;
wire SignA,SignB;

assign SignA = wALatched[31];
assign SignB = wBLatched[31];


assign wB = (SignB == 1) ? ~wBLatched + 1'b1 : wBLatched;
assign wA = (SignA == 1) ? ~wALatched + 1'b1 : wALatched;

assign w2A = wA << 1;
assign w3A = w2A + wA;

wire [31:0] wPartialResult0,wPartialResult1,wPartialResult2,wPartialResult3,wPartialResult4,wPartialResult5;
wire [31:0] wPartialResult6,wPartialResult7,wPartialResult8,wPartialResult9,wPartialResult10,wPartialResult11;
wire [31:0] wPartialResult12,wPartialResult13,wPartialResult14,wPartialResult15;

MUX_4_TO_1_32Bits_FullParallel MUX0
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[1],wB[0]} ),
		.O( wPartialResult0 )	
);


MUX_4_TO_1_32Bits_FullParallel MUX1
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[3],wB[2]} ),
		.O( wPartialResult1 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX2
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[5],wB[4]} ),
		.O( wPartialResult2 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX3
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[7],wB[6]} ),
		.O( wPartialResult3 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX4
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[9],wB[8]} ),
		.O( wPartialResult4 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX5
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[11],wB[10]} ),
		.O( wPartialResult5 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX6
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[13],wB[12]} ),
		.O( wPartialResult6 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX7
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[15],wB[14]} ),
		.O( wPartialResult7 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX8
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[17],wB[16]} ),
		.O( wPartialResult8 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX9
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[19],wB[18]} ),
		.O( wPartialResult9 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX10
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[21],wB[20]} ),
		.O( wPartialResult10 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX11
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[23],wB[22]} ),
		.O( wPartialResult11 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX12
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[25],wB[24]} ),
		.O( wPartialResult12 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX13
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[27],wB[26]} ),
		.O( wPartialResult13 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX14
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[29],wB[28]} ),
		.O( wPartialResult14 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX15
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[31],wB[30]} ),
		.O( wPartialResult15 )	
);



wire[63:0] wPartialResult1_0,wPartialResult1_1,wPartialResult1_2,wPartialResult1_3,
wPartialResult1_4,wPartialResult1_5,wPartialResult1_6,wPartialResult1_7;


assign wPartialResult1_0 = (wPartialResult0) + (wPartialResult1<<2);
assign wPartialResult1_1 = (wPartialResult2 << 4) + (wPartialResult3<<6);
assign wPartialResult1_2 = (wPartialResult4 << 8) + (wPartialResult5<<10);
assign wPartialResult1_3 = (wPartialResult6 << 12)+ (wPartialResult7<<14);
assign wPartialResult1_4 = (wPartialResult8 << 16)+ (wPartialResult9<<18);
assign wPartialResult1_5 = (wPartialResult10 << 20) + (wPartialResult11<< 22);
assign wPartialResult1_6 = (wPartialResult12 << 24) + (wPartialResult13 << 26);
assign wPartialResult1_7 = (wPartialResult14 << 28) + (wPartialResult15 << 30);




wire [63:0] wPartialResult2_0,wPartialResult2_1,wPartialResult2_2,wPartialResult2_3;

assign wPartialResult2_0 = wPartialResult1_0 + wPartialResult1_1;
assign wPartialResult2_1 = wPartialResult1_2 + wPartialResult1_3;
assign wPartialResult2_2 = wPartialResult1_4 + wPartialResult1_5;
assign wPartialResult2_3 = wPartialResult1_6 + wPartialResult1_7;

wire [63:0] wPartialResult3_0,wPartialResult3_1;

assign wPartialResult3_0 = wPartialResult2_0 + wPartialResult2_1;
assign wPartialResult3_1 = wPartialResult2_2 + wPartialResult2_3;

wire [63:0] R_pre1,R_pre2;

//assign R_pre1 = (wPartialResult3_0 + wPartialResult3_1);
assign R_pre1 = (iUnscaled == 1) ? (wPartialResult3_0 + wPartialResult3_1) : ((wPartialResult3_0 + wPartialResult3_1) >> `SCALE);

assign R_pre2 = ( (SignA ^ SignB) == 1) ? ~R_pre1 + 1'b1 : R_pre1;

//assign R = R_pre2 >> `SCALE;
assign R = R_pre2;

endmodule
