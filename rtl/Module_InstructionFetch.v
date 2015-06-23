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
/**********************************************************************************
Description:
 This is the instruction fetch unit.
 It gets the next instruction from the IMEM module at the MEM unit.
 It increments the instruction pointer (IP) in such a way that EXE has always
 one instruction per clock cycle (best pipeline performance). In order to achieve this,
 IFU has 2 instruction pointers, so that in case of 'branch' instructions,
 two instructions pointer are generated and two different instructions are simultaneously
 fetched from IMEM: the branch-taken and branch-not-taken instructions, so that once the
 branch outcome is calculted in EXE, both possible outcomes are already pre-fetched.
**********************************************************************************/
module InstructionFetch
(
input wire Clock,
input wire Reset,
input wire iTrigger,
input wire[`ROM_ADDRESS_WIDTH-1:0]		iInitialCodeAddress,
input wire[`INSTRUCTION_WIDTH-1:0]		iInstruction1,			//Branch not taken instruction
input wire[`INSTRUCTION_WIDTH-1:0]		iInstruction2,			//Branch taken instruction
input	wire										iBranchTaken,
output wire										oInstructionAvalable,
output wire [`ROM_ADDRESS_WIDTH-1:0]	oIP,
output wire [`ROM_ADDRESS_WIDTH-1:0]	oIP2, //calcule both decide later
output wire[`INSTRUCTION_WIDTH-1:0]		oCurrentInstruction,
input wire                             iEXEDone,
output wire										oMicroCodeReturnValue,
input wire                             iSubroutineReturn,
//input wire [`ROM_ADDRESS_WIDTH-1:0]    iReturnAddress,
output wire                            oExecutionDone
);
`define INSTRUCTION_OPCODE oCurrentInstruction[`INSTRUCTION_WIDTH-1:`INSTRUCTION_WIDTH-`INSTRUCTION_OP_LENGTH]


assign oMicroCodeReturnValue = oCurrentInstruction[0];
assign oIP2 = oCurrentInstruction[47:32];

wire wTriggerDelay1,wTriggerDelay2,wIncrementIP_Delay1,wIncrementIP_Delay2,
wLastInst_Delay1,wLastInst_Delay2;
wire wIncrementIP,wLastInstruction;
wire wInstructionAvalable,wSubReturnDelay1,wSubReturnDelay2;

assign wLastInstruction = (`INSTRUCTION_OPCODE == `RETURN );

wire IsCall;
reg [`ROM_ADDRESS_WIDTH-1:0]    rReturnAddress;
assign IsCall = ( `INSTRUCTION_OPCODE == `CALL ) ? 1'b1 : 1'b0;
always @ (posedge IsCall)
rReturnAddress <= oIP+1;

//Increment IP 2 cycles after trigger or everytime EXE is done, or 2 cycles after return from sub, but stop if we get to the RETURN
assign wIncrementIP =  wTriggerDelay2 | (iEXEDone & ~wLastInstruction) | wSubReturnDelay2;
//It takes 1 clock cycle to read the instruction back from IMEM


//Instructions become available to IDU: 
//* 2 cycles after IFU is initially triggered
//* Everytime previous instruction execution is complete except for the last instruction in
//the flow
assign wInstructionAvalable = wTriggerDelay2 | (iEXEDone & ~wLastInst_Delay2);


FFD_POSEDGE_SYNCRONOUS_RESET # ( 1 ) FFD22
(
	.Clock( Clock ),
	.Reset( Reset ),
	.Enable(1'b1),
	.D( iSubroutineReturn ),
	.Q( wSubReturnDelay1 )
);

FFD_POSEDGE_SYNCRONOUS_RESET # ( 1 ) FFD23
(
	.Clock( Clock ),
	.Reset( Reset ),
	.Enable(1'b1),
	.D( wSubReturnDelay1 ),
	.Q( wSubReturnDelay2 )
);
//Special case for instruction available pin: if a return from subroutine instruction was issued,
//then wait 1 cycle before anouncing Instruction available to IDU
assign oInstructionAvalable =  wInstructionAvalable & ~iSubroutineReturn | wSubReturnDelay2;





//Once we reach the last instruction, wait until EXE says he is done, then assert oExecutionDone
assign oExecutionDone = (wLastInstruction & iEXEDone);

FFD_POSEDGE_SYNCRONOUS_RESET # ( 1 ) FFD2
(
	.Clock( Clock ),
	.Reset( Reset ),
	.Enable(1'b1),
	.D( iTrigger ),
	.Q( wTriggerDelay1 )
);


FFD_POSEDGE_SYNCRONOUS_RESET # ( 1 ) FFD3
(
	.Clock( Clock ),
	.Reset( Reset ),
	.Enable(1'b1),
	.D( wTriggerDelay1 ),
	.Q( wTriggerDelay2 )
);


FFD_POSEDGE_SYNCRONOUS_RESET # ( 1 ) FFD4
(
	.Clock( Clock ),
	.Reset( Reset ),
	.Enable(wLastInstruction),
	.D( oInstructionAvalable ),
	.Q( wLastInst_Delay1 )
);


FFD_POSEDGE_SYNCRONOUS_RESET # ( 1 ) FFD5
(
	.Clock( Clock ),
	.Reset( Reset ),
	.Enable(1'b1),//wLastInstruction),
	.D( wLastInst_Delay1 ),
	.Q( wLastInst_Delay2 )
);

wire [`ROM_ADDRESS_WIDTH-1:0] oIP2_Next;

/*
In case the branch is taken:
We point current instruction into the iInstruction2 (branch-taken) instruction
that corresponds to oIP2. 
Then, in the next clock cycle we should use the oIP2 incremented by one,
so we need to load UPCOUNTER_POSEDGE with oIP2+1
*/


//If the branch was taken, then use the pre-fetched instruction (iInstruction2)
wire[`INSTRUCTION_WIDTH-1:0] wCurrentInstruction_Delay1,wCurrentInstruction_BranchTaken;
FFD_POSEDGE_SYNCRONOUS_RESET # ( `INSTRUCTION_WIDTH ) FFDX
(
	.Clock( Clock ),
	.Reset( Reset ),
	.Enable(iBranchTaken),
	.D( oCurrentInstruction ),
	.Q( wCurrentInstruction_Delay1 )
);

wire wBranchTaken_Delay1;
FFD_POSEDGE_SYNCRONOUS_RESET # ( 1 ) FFDY
(
	.Clock( Clock ),
	.Reset( Reset ),
	.Enable(1'b1),
	.D( iBranchTaken ),
	.Q( wBranchTaken_Delay1 )
);


assign wCurrentInstruction_BranchTaken = ( iBranchTaken & ~iSubroutineReturn) ? iInstruction2 : iInstruction1;

assign oCurrentInstruction = (wBranchTaken_Delay1 ) ? 
wCurrentInstruction_Delay1 : wCurrentInstruction_BranchTaken;

INCREMENT # (`ROM_ADDRESS_WIDTH) INC1 
(
.Clock( Clock ),
.Reset( Reset ),
.A( oIP2 ),
.R( oIP2_Next )
);

wire[`ROM_ADDRESS_WIDTH-1:0] wIPEntryPoint;
//assign wIPEntryPoint = (iBranchTaken) ? oIP2_Next : iInitialCodeAddress;

//iReturnAddress is a register stored @ IDU everytime a CALL instruction is decoded
assign wIPEntryPoint = (iBranchTaken & ~wBranchTaken_Delay1) ? (iSubroutineReturn) ? rReturnAddress : oIP2_Next  : iInitialCodeAddress;


UPCOUNTER_POSEDGE # (`ROM_ADDRESS_WIDTH) InstructionPointer
(
	.Clock( Clock ), 
	.Reset(iTrigger | (iBranchTaken & ~wBranchTaken_Delay1)),
	.Enable(wIncrementIP & (~iBranchTaken | wBranchTaken_Delay1 ) ),
	.Initial( wIPEntryPoint ),
	.Q(oIP)
);


endmodule

//-------------------------------------------------------------------------------