`timescale 1ns / 1ps
`include "aDefinitions.v"

module Module_OMemInterface
(
	input wire Clock,
	input wire Reset,
	input wire                  iWriteEnable,
	input wire [`DATA_ROW_WIDTH-1:0]     iData,
	input wire [`DATA_ROW_WIDTH-1:0]     iAddress,
	output wire [`WB_WIDTH-1:0] ADR_O,
	output wire[`WB_WIDTH-1:0]  DAT_O,
	output wire					    WE_O
	
);
wire [2:0] wCurrentWord;
assign WE_O = iWriteEnable;

CIRCULAR_SHIFTLEFT_POSEDGE #(3) SHL
( 
  .Clock(Clock),
  .Enable(iWriteEnable),			
  .Reset(Reset), 
  .Initial(3'b1), 
  .O(wCurrentWord)
  
);

MUXFULLPARALELL_3SEL_WALKINGONE # ( `WB_WIDTH ) MUX1
 (
	.Sel( wCurrentWord ),
	.I3(iAddress[31:0]),
	.I2(iAddress[63:32]),
	.I1(iAddress[95:64]),
	.O1( ADR_O )
 );
 
 MUXFULLPARALELL_3SEL_WALKINGONE # ( `WB_WIDTH ) MUX2
 (
	.Sel( wCurrentWord ),
	.I3(iData[31:0]),
	.I2(iData[63:32]),
	.I1(iData[95:64]),
	.O1( DAT_O )
 );
 
endmodule
