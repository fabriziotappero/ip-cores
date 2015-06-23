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

//---------------------------------------------------------------------
module ExecutionUnit
(

input wire                             Clock,
input wire                             Reset,
input wire [`ROM_ADDRESS_WIDTH-1:0]	   iInitialCodeAddress, 
input wire [`INSTRUCTION_WIDTH-1:0] 	iInstruction1,
input wire [`INSTRUCTION_WIDTH-1:0] 	iInstruction2,


input wire [`DATA_ROW_WIDTH-1:0] 		iDataRead0, 
input wire [`DATA_ROW_WIDTH-1:0]       iDataRead1, 				
input wire                             iTrigger, 


output wire [`ROM_ADDRESS_WIDTH-1:0]	oInstructionPointer1,
output wire [`ROM_ADDRESS_WIDTH-1:0]	oInstructionPointer2,
output wire [`DATA_ADDRESS_WIDTH-1:0]	oDataReadAddress0, 
output wire [`DATA_ADDRESS_WIDTH-1:0]  oDataReadAddress1,
output wire 									oDataWriteEnable,	
output wire [`DATA_ADDRESS_WIDTH-1:0]	oDataWriteAddress,
output wire [`DATA_ROW_WIDTH-1:0]		oDataBus,		   
output wire                            oReturnCode,


output wire [`DATA_ROW_WIDTH-1:0]    oOMEMWriteAddress,
output wire [`DATA_ROW_WIDTH-1:0]    oOMEMWriteData,
output wire                 		    oOMEMWriteEnable,
output wire [`DATA_ROW_WIDTH-1:0]    oTMEMReadAddress,
input wire [`DATA_ROW_WIDTH-1:0]     iTMEMReadData,
input wire                           iTMEMDataAvailable,
output wire                          oTMEMDataRequest,

`ifdef DEBUG
input wire [`MAX_CORES-1:0]            iDebug_CoreID,
`endif
output wire                            oDone 




);


`ifdef DEBUG
	wire [`ROM_ADDRESS_WIDTH-1:0] wDEBUG_IDU2_EXE_InstructionPointer;
`endif

wire 										wEXE2__uCodeDone;
wire										wEXE2_IFU__EXEBusy;
wire [`DATA_ADDRESS_WIDTH-1:0]	wEXE2_IDU_DataFordward_LastDestination;
wire 										wALU2_EXE__BranchTaken;
wire 										wALU2_IFU_BranchNotTaken;
wire [`INSTRUCTION_WIDTH-1:0] 	CurrentInstruction;
//wire										wIDU2_IFU__IDUBusy;


wire [`INSTRUCTION_OP_LENGTH-1:0]				wOperation;


wire [`DATA_ROW_WIDTH-1:0] wSource0,wSource1;
wire [`DATA_ADDRESS_WIDTH-1:0] wDestination;
wire wInstructionAvailable;

//ALU wires
wire [`INSTRUCTION_OP_LENGTH-1:0] 		ALU2Operation;
wire [`WIDTH-1:0] 					ALU2ChannelA;
wire [`WIDTH-1:0] 					ALU2ChannelB;
wire [`WIDTH-1:0] 					ALU2ChannelC;
wire [`WIDTH-1:0] 					ALU2ChannelD;
wire [`WIDTH-1:0] 					ALU2ChannelE;
wire [`WIDTH-1:0] 					ALU2ChannelF;
wire [`WIDTH-1:0] 					ALU2ResultA;
wire [`WIDTH-1:0] 					ALU2ResultB;
wire [`WIDTH-1:0] 					ALU2ResultC;
wire										wEXE2_ALU__TriggerALU;
wire										ALU2OutputReady;
wire 										w2FIU__BranchTaken;
wire	[`ROM_ADDRESS_WIDTH-1:0]	JumpIp;
wire  [`ROM_ADDRESS_WIDTH-1:0]   wIDU2_IFU_ReturnAddress;
wire                             wALU2_IFU_ReturnFromSub;

//wire wIDU2_IFU__InputsLatched;	

wire wEPU_Busy,wTriggerIFU;
wire [`ROM_ADDRESS_WIDTH-1:0] wEPU_IP,wIFU_IP,wCodeEntryPoint;

assign oInstructionPointer1 = (wEPU_Busy) ? wEPU_IP : wIFU_IP;


InstructionEntryPoint EPU
(
.Clock( Clock ),
.Reset( Reset ),
.iTrigger( iTrigger ),
.iInitialCodeAddress( iInitialCodeAddress ),
.iIMemInput(iInstruction1),

.oEPU_Busy(wEPU_Busy),
.oEntryPoint( wCodeEntryPoint ),
.oTriggerIFU( wTriggerIFU ),
.oInstructionAddr( wEPU_IP )

);

InstructionFetch IFU
(
.Clock( Clock                                  ),
.Reset( Reset                                  ),
.iTrigger(              wTriggerIFU            ),
.iInstruction1(         iInstruction1          ),	
.iInstruction2(         iInstruction2          ),
.iInitialCodeAddress(   wCodeEntryPoint        ),
.iBranchTaken(          w2FIU__BranchTaken     ),
.iSubroutineReturn(     wALU2_IFU_ReturnFromSub ),
//.iReturnAddress(        wIDU2_IFU_ReturnAddress ),
.oCurrentInstruction(   CurrentInstruction      ),		
.oInstructionAvalable(  wInstructionAvailable   ),
.oIP(                   wIFU_IP                 ),
.oIP2(                  oInstructionPointer2    ),
.iEXEDone(              ALU2OutputReady         ),
.oMicroCodeReturnValue( oReturnCode             ),	
.oExecutionDone(        oDone                   )
);

////---------------------------------------------------------
wire wIDU2_EXE_DataReady;
wire wEXE2_IDU_ExeLatchedValues;

InstructionDecode IDU
(
	.Clock( Clock ),
	.Reset( Reset ),
	.iEncodedInstruction( CurrentInstruction ),
	.iInstructionAvailable( wInstructionAvailable ),
	//.iIP( oInstructionPointer1 ),
	//.oReturnAddress( wIDU2_IFU_ReturnAddress ),
	
	.oRamAddress0( oDataReadAddress0 ),
	.oRamAddress1( oDataReadAddress1 ),
	.iRamValue0( iDataRead0 ),
	.iRamValue1( iDataRead1 ),
	
	.iLastDestination( wEXE2_IDU_DataFordward_LastDestination ),
	.iDataForward( {ALU2ResultA,ALU2ResultB,ALU2ResultC} ),
	
	//Outputs going to the ALU-FSM
	.oOperation( wOperation ),
	.oDestination( wDestination ),
	.oSource0( wSource0 ),
	.oSource1( wSource1  ),
	
	`ifdef DEBUG
	.iDebug_CurrentIP( oInstructionPointer1 ),
	.oDebug_CurrentIP( wDEBUG_IDU2_EXE_InstructionPointer ),
	`endif
	
	.oDataReadyForExe( wIDU2_EXE_DataReady )
	
	
	
	
	
);


ExecutionFSM	 EXE
(
	.Clock( Clock ),
	.Reset( Reset | iTrigger ),  //New Sat Jun13
	.iDecodeDone( wIDU2_EXE_DataReady ),
	.iOperation( wOperation ),
	.iDestination( wDestination ),
	.iSource0( wSource0 ),
	.iSource1( wSource1 ) ,

	
	`ifdef DEBUG
		.iDebug_CurrentIP( wDEBUG_IDU2_EXE_InstructionPointer ),
		.iDebug_CoreID( iDebug_CoreID ),
	`endif
	
	//.iJumpResultFromALU( wALU2_EXE__BranchTaken ),
	.iBranchTaken( wALU2_EXE__BranchTaken ),
	.iBranchNotTaken( wALU2_IFU_BranchNotTaken ),
	.oJumpFlag( w2FIU__BranchTaken ),
	.oJumpIp( JumpIp ),	
	.oRAMWriteEnable( oDataWriteEnable ),
	.oRAMWriteAddress( oDataWriteAddress ),
	.RAMBus( oDataBus ),
	.oBusy( wEXE2_IFU__EXEBusy ),

	.oExeLatchedValues( wEXE2_IDU_ExeLatchedValues ),
	.oLastDestination( wEXE2_IDU_DataFordward_LastDestination ),

	//ALU ports and control signals
	.oTriggerALU( wEXE2_ALU__TriggerALU ),
	.oALUOperation( ALU2Operation ),
	.oALUChannelX1( ALU2ChannelA ),
	.oALUChannelX2( ALU2ChannelB ),
	.oALUChannelY1( ALU2ChannelC ),
	.oALUChannelY2( ALU2ChannelD ),
	.oALUChannelZ1( ALU2ChannelE ),
	.oALUChannelZ2( ALU2ChannelF ),
	.iALUResultX( ALU2ResultA ),
	.iALUResultY( ALU2ResultB ),
	.iALUResultZ( ALU2ResultC ),
	.iALUOutputReady( ALU2OutputReady )

);


//--------------------------------------------------------

VectorALU ALU
(
	.Clock(Clock), 
	.Reset(Reset), 
	.iOperation( ALU2Operation ),
	.iChannel_Ax( ALU2ChannelA ),
	.iChannel_Bx( ALU2ChannelB ),
	.iChannel_Ay( ALU2ChannelC ),
	.iChannel_By( ALU2ChannelD ),
	.iChannel_Az( ALU2ChannelE ),
	.iChannel_Bz( ALU2ChannelF ),
	.oResultA( ALU2ResultA ),
	.oResultB( ALU2ResultB ),
	.oResultC( ALU2ResultC ),
	.oBranchTaken( wALU2_EXE__BranchTaken ),
	.oBranchNotTaken( wALU2_IFU_BranchNotTaken ),
	.oReturnFromSub( wALU2_IFU_ReturnFromSub ),
	.iInputReady( wEXE2_ALU__TriggerALU ),
	
	//***********
	.oOMEMWriteAddress(   oOMEMWriteAddress ),
	.oOMEMWriteData(      oOMEMWriteData    ),
	.oOMEM_WriteEnable(   oOMEMWriteEnable ),
	
	.oTMEMReadAddress(     oTMEMReadAddress ),
	.iTMEMReadData(        iTMEMReadData    ),
	.iTMEMDataAvailable(   iTMEMDataAvailable ),
	.oTMEMDataRequest(     oTMEMDataRequest   ),
	//***********
	.iCurrentIP( oInstructionPointer1 ),
	.OutputReady( ALU2OutputReady )
	
);
	


endmodule
//---------------------------------------------------------------------