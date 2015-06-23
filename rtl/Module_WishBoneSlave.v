`timescale 1ns / 1ps
`include "aDefinitions.v"



`define TAG_INSTRUCTION_ADDRESS_TYPE 2'b10
`define TAG_DATA_ADDRESS_TYPE    2'b01
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
//------------------------------------------------------------------------------
module WishBoneSlaveUnit
(
//WB Input signals
input wire 						   CLK_I,
input wire						   RST_I,
input wire                    STB_I,
input wire                    WE_I,
input wire[`WB_WIDTH-1:0]     DAT_I,
input wire[`WB_WIDTH-1:0]     ADR_I,
input wire [1:0]              TGA_I,
output wire                   ACK_O,
input wire                    MST_I,   //Master In!
input wire                    CYC_I,
output wire[`DATA_ADDRESS_WIDTH-1:0] 	oDataWriteAddress,
output wire [`DATA_ROW_WIDTH-1:0]		oDataBus,
output wire [`ROM_ADDRESS_WIDTH-1:0]   oInstructionWriteAddress,
output wire [`INSTRUCTION_WIDTH-1:0]	oInstructionBus,
output wire										oDataWriteEnable,
output wire										oInstructionWriteEnable

);

FFD_POSEDGE_SYNCRONOUS_RESET # (16) FFADR 
(
	.Clock( CYC_I ),
	.Reset( RST_I ),
	.Enable(1'b1),
	.D( ADR_I[15:0] ),
	.Q( oInstructionWriteAddress )
);

assign oDataWriteAddress = oInstructionWriteAddress;

wire[1:0] wTGA_Latched;

FFD_POSEDGE_SYNCRONOUS_RESET # (2) FFADDRTYPE 
(
	.Clock( CYC_I ),
	.Reset( RST_I ),
	.Enable(1'b1),
	.D( TGA_I ),
	.Q( wTGA_Latched )
);



wire Clock,Reset;
assign Clock = CLK_I;
assign Reset = RST_I;


wire wLatchNow;
assign wLatchNow = STB_I & WE_I;

//1 Clock cycle after we assert the latch signal
//then the FF has the data ready to propagate
wire wDelay;
FFD_POSEDGE_SYNCRONOUS_RESET # (1) FFOutputDelay 
(
	.Clock( Clock ),
	.Enable( 1'b1 ),
	.Reset( Reset ),
	.D( wLatchNow ),
	.Q( wDelay )
);

assign ACK_O = wDelay & STB_I; //make sure we set ACK_O back to zero when STB_I is zero


wire [2:0] wXYZSel;

SHIFTLEFT_POSEDGE #(3) SHL
( 
  .Clock(CLK_I),
  .Enable(STB_I & ~ACK_O),
  .Reset(~CYC_I), 
  .Initial(3'b1), 
  .O(wXYZSel)
  
);


//Flip Flop to Store Vx
wire [`WIDTH-1:0] wVx;
FFD_POSEDGE_SYNCRONOUS_RESET # (`WIDTH) FFD32_WBS2MEM_Vx 
(
	.Clock( 	Clock ),
	.Reset( 	Reset ),
	.Enable( wXYZSel[0] &  STB_I ),
	.D( DAT_I ),
	.Q( wVx )
	
);


//Flip Flop to Store Vy
wire [`WIDTH-1:0] wVy;
FFD_POSEDGE_SYNCRONOUS_RESET # (`WIDTH) FFD32_WBS2MEM_Vy 
(
	.Clock( 	Clock ),
	.Reset( 	Reset ),
	.Enable(  wXYZSel[1] &  STB_I ),
	.D( DAT_I ),
	.Q( wVy )
	
);

//Flip Flop to Store Vz
wire [`WIDTH-1:0] wVz;

FFD_POSEDGE_SYNCRONOUS_RESET # (`WIDTH) FFD32_WBS2MEM_Vz 
(
	.Clock( 	Clock ),
	.Reset( 	Reset ),
	.Enable(  wXYZSel[2] &  STB_I ),
	.D( DAT_I ),
	.Q( wVz )
);

assign oDataBus 		  = {wVx,wVy,wVz};
assign oInstructionBus = {wVx,wVy};
wire wIsInstructionAddress,wIsDataAddress;
assign wIsInstructionAddress = (wTGA_Latched == `TAG_INSTRUCTION_ADDRESS_TYPE)  ? 1'b1 : 1'b0;
assign wIsDataAddress = (wTGA_Latched == `TAG_DATA_ADDRESS_TYPE )  ? 1'b1 : 1'b0;

assign oDataWriteEnable = (MST_I && !CYC_I && wIsInstructionAddress) ? 1'b1 : 1'b0;
assign oInstructionWriteEnable = ( MST_I && !CYC_I && wIsDataAddress) ? 1'b1 : 1'b0;



endmodule
//------------------------------------------------------------------------------