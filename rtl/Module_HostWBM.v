`timescale 1ns / 1ps
`include "aDefinitions.v"

//---------------------------------------------------------------
module WBMaster
(
	input wire Clock,
	input wire Reset,
	input wire iEnable,
	input wire iShortFlow,
	input wire [`WB_WIDTH-1:0]  iInitialReadAddr,
	input wire [`WB_WIDTH-1:0]  iWriteAddr,
	output wire [`WB_WIDTH-1:0] oReadAddress,
	input wire [`WB_WIDTH-1:0]  iReadData,
	
	output reg  STB_O,
	input wire   ACK_I,
	output wire  CYC_O,
	output wire [`WB_WIDTH-1:0] DAT_O,
	output wire [`WB_WIDTH-1:0] ADR_O,
	output wire oDone
);

	assign ADR_O = iWriteAddr;
	wire [3:0] wXYZSel_Long;
	wire [2:0] wXYZSel_Short;

	UPCOUNTER_POSEDGE # (`WB_WIDTH) WBM_O_READ_ADDRESS
	(
	.Clock(Clock), 
	.Reset( Reset ),
	.Enable(iEnable & ACK_I),
	.Initial(iInitialReadAddr),
	.Q(oReadAddress)
	);
	
	CIRCULAR_SHIFTLEFT_POSEDGE #(4) SHL
	( 
  .Clock(Clock),
  .Enable(ACK_I & iEnable),
  .Reset( Reset ), 
  .Initial(4'b1), 
  .O(wXYZSel_Long)
  
	);
	CIRCULAR_SHIFTLEFT_POSEDGE #(3) SHL2
	( 
  .Clock(Clock),
  .Enable(ACK_I & iEnable),
  .Reset( Reset ), 
  .Initial(3'b1), 
  .O(wXYZSel_Short)
  
	);
	
	assign oDone = (iShortFlow) ? wXYZSel_Short[2] : wXYZSel_Long[3];
	assign DAT_O = iReadData;

	assign CYC_O = iEnable;
	
	always @ (posedge Clock)
	begin
	if (iEnable )
		STB_O <= ~ACK_I;
	else
		STB_O <= 0;
	end


endmodule
