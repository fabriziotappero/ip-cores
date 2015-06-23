`timescale 1ns / 1ps
`include "aDefinitions.v"
/**********************************************************************************
Theia, Ray Cast Programable graphic Processing Unit.
Copyright (C) 2010  Diego Valverde (diego.valverde.g@gmail.com)

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

***********************************************************************************/

module InstructionDecode
(
input wire											Clock,
input wire											Reset,
input wire											iInstructionAvailable,
input	wire[`INSTRUCTION_WIDTH-1:0]			iEncodedInstruction,
input	wire[`DATA_ROW_WIDTH-1:0]				iRamValue0,										
input	wire[`DATA_ROW_WIDTH-1:0]				iRamValue1,										
output  wire[`DATA_ADDRESS_WIDTH-1:0]		oRamAddress0,oRamAddress1,
output  wire[`INSTRUCTION_OP_LENGTH-1:0]	oOperation,
output  wire [`DATA_ROW_WIDTH-1:0]			oSource0,oSource1,
output  wire [`DATA_ADDRESS_WIDTH-1:0]	   oDestination,
input wire [`DATA_ROW_WIDTH-1:0]          iDataForward,
input wire [`DATA_ADDRESS_WIDTH-1:0]      iLastDestination,

`ifdef DEBUG
	input wire [`ROM_ADDRESS_WIDTH-1:0] iDebug_CurrentIP,
	output wire [`ROM_ADDRESS_WIDTH-1:0] oDebug_CurrentIP,
`endif

//input wire   [`ROM_ADDRESS_WIDTH-1:0]	   iIP,
//output reg  [`ROM_ADDRESS_WIDTH-1:0]     oReturnAddress,
output wire                               oDataReadyForExe

);
wire wInmediateOperand;
wire [`DATA_ROW_WIDTH-1:0]	wSource0,wSource1;
wire wTriggerSource0DataForward,wTriggerSource1DataForward;
wire wSource0AddrssEqualsLastDestination,wSource1AddrssEqualsLastDestination;

`ifdef DEBUG
assign oDebug_CurrentIP = iDebug_CurrentIP;
`endif
//See if operation takes scalar argument
assign wInmediateOperand = iEncodedInstruction[`INSTRUCTION_IMM_BITPOS];

//Has the value of the first argument fetched from IMEM
assign wSource0 = iRamValue0;
//Has the value of the second argument fetched from IMEM, or the value of the
//destinatin register in case of scalar operation
assign wSource1 = ( wInmediateOperand ) ? {oRamAddress1,iEncodedInstruction[15:0] ,32'b0,32'b0} : iRamValue1; //{oRamAddress1,oRamAddress0,32'b0,32'b0} : iRamValue1;

//Data forwarding logic
assign wSource0AddrssEqualsLastDestination = (oRamAddress0 == iLastDestination) ? 1'b1: 1'b0;
assign wSource1AddrssEqualsLastDestination = (oRamAddress1 == iLastDestination) ? 1'b1: 1'b0;
assign wTriggerSource0DataForward = wSource0AddrssEqualsLastDestination;
assign wTriggerSource1DataForward = wSource1AddrssEqualsLastDestination && !wInmediateOperand;

//The data address to fetch from IMEM
assign oRamAddress1 = iEncodedInstruction[31:16];

//If operation takes a scalar value, then ask IMEM
//for the previous value of the destination ([47:32])
//and have this value ready at oRamAddress0
MUXFULLPARALELL_16bits_2SEL RAMAddr0MUX 
 (
  .Sel( wInmediateOperand ),
  .I1( iEncodedInstruction[15:0] ),
  .I2( iEncodedInstruction[47:32] ),
  .O1( oRamAddress0 )
 );


//One clock cycle after the new instruction becomes
//available to IDU, it should be decoded and ready 
//for execution
FFD_POSEDGE_SYNCRONOUS_RESET # ( 1 ) FFD1
(
	.Clock( Clock ),
	.Reset( Reset ),
	.Enable(1'b1),
	.D( iInstructionAvailable ),
	.Q( oDataReadyForExe )
);

/*
wire IsCall;
assign IsCall = ( oOperation == `CALL ) ? 1'b1 : 1'b0;
always @ (posedge IsCall)
oReturnAddress <= iIP;
*/
/* 
FFD_POSEDGE_SYNCRONOUS_RESET # ( `ROM_ADDRESS_WIDTH ) FFRETURNADDR
(
	.Clock( Clock ),
	.Reset( Reset ),
	.Enable( IsCall ),
	.D( iIP ),
	.Q( oReturnAddress )
);
*/


//Latch the Operation
FFD_POSEDGE_SYNCRONOUS_RESET # ( `INSTRUCTION_OP_LENGTH ) FFD3
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(iInstructionAvailable),
	.D(iEncodedInstruction[`INSTRUCTION_WIDTH-1:`INSTRUCTION_WIDTH-`INSTRUCTION_OP_LENGTH]),
	.Q( oOperation )
);
//Latch the Destination
FFD_POSEDGE_SYNCRONOUS_RESET # ( `DATA_ADDRESS_WIDTH ) FFD2
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(iInstructionAvailable),
	.D(iEncodedInstruction[47:32]),
	.Q(oDestination )
);


//Once we made a decicions if the Sources must be forwarded or not, a series of muxes
//are used to routed the correct data into the decoded Source outputs

MUXFULLPARALELL_96bits_2SEL Source0_Mux
(
	.Sel( wTriggerSource0DataForward ),
	.I1( wSource0  ),
	.I2( iDataForward ),
	.O1( oSource0 )
);

MUXFULLPARALELL_96bits_2SEL Source1_Mux
(
	.Sel( wTriggerSource1DataForward ),
	.I1( wSource1  ),
	.I2( iDataForward ),
	.O1( oSource1 )
);

endmodule

