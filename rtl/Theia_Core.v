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
 This is the top level block for THEIA.
 THEIA core has 5 main logical blocks called Units.
 This module implements the interconections between the Units.
 
 Units:
  > EXE: Mananges execution logic for the SHADERS.
  > GEO: Manages geometry data structures.
  > IO: Input/Output (Wishbone).
  > MEM: Internal memory, separate for Instructions and data.
  > CONTROL: Main control Finite state machine.
  
 Internal Buses: 
	THEIA has separate instruction and data buses.
	THEIA avoids using tri-state buses by having separate input/output
	for each bus. 
	There are 2 separate data buses since the Data memory 
	has a Dual read channel.
   Please see the MEM unit chapter in the documentation for more details.
 
 External Buses:
	External buses are managed by the IO Unit.
	External buses follow the wishbone protocol.
	Please see the IO unit chapter in the documentation for more details.
**********************************************************************************/

`timescale 1ns / 1ps
`include "aDefinitions.v"

module THEIACORE
(

input wire                    CLK_I,	//Input clock
input wire                    RST_I,	//Input reset
//Theia Interfaces
input wire                    MST_I,	//Master signal, THEIA enters configuration mode
                                       //when this gets asserted (see documentation)
//Wish Bone Interface
input wire [`WB_WIDTH-1:0]    DAT_I,	//Input data bus  (Wishbone)
output wire [`WB_WIDTH-1:0]   DAT_O,	//Output data bus (Wishbone)
input wire                    ACK_I,	//Input ack
output wire                   ACK_O,	//Output ack
output wire [`WB_WIDTH-1:0]   ADR_O,	//Output address
input wire [`WB_WIDTH-1:0]    ADR_I,	//Input address
output wire                   WE_O,		//Output write enable
input wire                    WE_I,    //Input write enable
output wire                   STB_O,	//Strobe signal, see wishbone documentation
input wire                    STB_I,	//Strobe signal, see wishbone documentation
output wire                   CYC_O,	//Bus cycle signal, see wishbone documentation
input wire                    CYC_I,   //Bus cycle signal, see wishbone documentation
output wire	[1:0]             TGC_O,   //Bus cycle tag, see THEAI documentation
input wire [1:0]              TGA_I,   //Input address tag, see THEAI documentation
output wire [1:0]             TGA_O,   //Output address tag, see THEAI documentation
input wire	[1:0]             TGC_I,   //Bus cycle tag, see THEAI documentation
input wire                    GNT_I,   //Bus arbiter 'Granted' signal, see THEAI documentation
input wire                    RENDREN_I,

output wire                  HDL_O,		//Data Latched
input wire                   HDLACK_I, //Data Latched ACK
input wire                   STDONE_I,		//Scene traverse complete
input wire                   HDA_I,
output wire                  RCOMMIT_O,

output wire [`WB_WIDTH-1:0] OMEM_DAT_O,
output wire [`WB_WIDTH-1:0] OMEM_ADR_O,
output wire						 OMEM_WE_O,

input wire                  TMEM_ACK_I,
input wire [`WB_WIDTH-1:0]  TMEM_DAT_I , 
output wire [`WB_WIDTH-1:0] TMEM_ADR_O ,
output wire                 TMEM_WE_O,
output wire                 TMEM_STB_O,
output wire                 TMEM_CYC_O,
input wire                  TMEM_GNT_I,

`ifdef DEBUG
input wire[`MAX_CORES-1:0]    iDebug_CoreID,
`endif
//Control Register
input wire [15:0]		         CREG_I,
output wire                   DONE_O


);

//When we flip the SMEM, this means we are ready to receive more data


//Alias this signals
wire Clock,Reset;
assign Clock = CLK_I;
assign Reset = RST_I;

wire                              wIO_Busy;
wire [`DATA_ROW_WIDTH-1:0]			 wEXE_2__MEM_WriteData;
wire [`DATA_ROW_WIDTH-1:0]			 wUCODE_RAMBus;
wire [`DATA_ADDRESS_WIDTH-1:0]	 wEXE_2__MEM_wDataWriteAddress;
wire                              w2IO__AddrIsImm;
wire [`DATA_ADDRESS_WIDTH-1:0]	 wUCODE_RAMAddress;
wire [`DATA_ADDRESS_WIDTH-1:0]    w2IO__Adr_O_Pointer;
wire [`DATA_ADDRESS_WIDTH-1:0]    wGEO2_IO__Adr_O_Pointer;
wire 										 wEXE_2__DataWriteEnable;
wire 										 wUCODE_RAMWriteEnable;
//wire [2:0]								 RamBusOwner;
//Unit intercoanection wires

wire 										wCU2__MicrocodeExecutionDone;
wire [`ROM_ADDRESS_WIDTH-1:0]		InitialCodeAddress; 
wire [`ROM_ADDRESS_WIDTH-1:0]		wInstructionPointer1,wInstructionPointer2;
wire [`INSTRUCTION_WIDTH-1:0] 	wEncodedInstruction1,wEncodedInstruction2,wIO2_MEM__ExternalInstruction;
wire			 							wCU2__ExecuteMicroCode;
wire  [`ROM_ADDRESS_WIDTH-1:0]   wIO2_MEM__InstructionWriteAddr;
wire [95:0] 							wMEM_2__EXE_DataRead0, wMEM_2__EXE_DataRead1,wMEM_2__IO_DataRead0, wMEM_2__IO_DataRead1; 				
wire [`DATA_ADDRESS_WIDTH-1:0]	wEXE_2__MEM_DataReadAddress0,wEXE_2__MEM_DataReadAddress1; 			
wire [`DATA_ADDRESS_WIDTH-1:0]	wUCODE_RAMReadAddress0,wUCODE_RAMReadAddress1;


wire [`WIDTH-1:0] 					w2IO__AddressOffset;
wire [`DATA_ADDRESS_WIDTH-1:0] 	w2IO__DataWriteAddress;
wire 										w2IO__Store;
wire 										w2IO__EnableWBMaster;

wire [`DATA_ADDRESS_WIDTH-1:0] 	wIO2_MEM__DataWriteAddress;
wire [`DATA_ADDRESS_WIDTH-1:0] 	wIO_2_MEM__DataReadAddress0;
wire [`DATA_ROW_WIDTH-1:0] 		wIO2_MEM__Bus;
wire [`WIDTH-1:0] 					wIO2_MEM__Data;
wire [`WIDTH-1:0] 					wIO2_WBM__Address;
wire 										wIO2_MEM__DataWriteEnable;
wire 										wIO2__Done;
wire 										wCU2_GEO__GeometryFetchEnable;
wire 										wIFU2__MicroCodeReturnValue;
wire 										wCU2_BCU__ACK;
wire 										wGEO2_CU__RequestAABBIU;
wire 										wGEO2_CU__RequestBIU;
wire                             wGEO2_CU__RequestTCC;
wire										wGEO2_CU__GeometryUnitDone;
wire										wGEO2_CU__Sync;
wire 										wEXE2__uCodeDone;
wire										wEXE2_IFU__EXEBusy;
wire [`DATA_ADDRESS_WIDTH-1:0]	wEXE2_IDU_DataFordward_LastDestination;
wire 										wALU2_EXE__BranchTaken;
wire 										wALU2_IFU_BranchNotTaken;
wire										w2IO__SetAddress;
wire										wIDU2_IFU__IDUBusy;
//Control Registe wires
wire[15:0]								wCR2_ControlRegister;
wire										wCR2_TextureMappingEnabled;
wire                             wGEO2_CU__TFFDone;
wire                             wCU2_GEO__TriggerTFF;
wire                             wIO2_MEM_InstructionWriteEnable;
wire                             wCU2_IO__WritePixel;
wire                             wGEO2_IO__AddrIsImm;
wire[31:0]                       wGEO2_IO__AddressOffset;
wire                             wGEO2_IO__EnableWBMaster;
wire                             wGEO2_IO__SetAddress;
wire[`WIDTH-1:0]                 wGEO2__CurrentPitch,wCU2_GEO_Pitch; 
wire                             wCU2_GEO__SetPitch,wCU2_GEO__IncPicth;

wire [`DATA_ROW_WIDTH-1:0] wEXE_2__IO_WriteAddress;
wire [`DATA_ROW_WIDTH-1:0] wEXE_2__IO_WriteData;
wire wEXE_2__IO_OMEMWriteEnable;

wire [`DATA_ROW_WIDTH-1:0] wEXE_2__IO_TMEMAddress;
wire [`DATA_ROW_WIDTH-1:0] wIO_2_EXE__TMEMData;
wire wIO_2_EXE__DataAvailable;
wire wEXE_2_IO__DataRequest;
wire wCU2_FlipMem;
wire wCU2_FlipMemEnabled;
wire w2MEM_FlipMemory;
wire wGEO2__RequestingTextures;
wire w2IO_WriteBack_Set;
wire[`DATA_ADDRESS_WIDTH-1:0] wIO_2_MEM__DataReadAddress1;

`ifdef DEBUG
	wire [`ROM_ADDRESS_WIDTH-1:0] wDEBUG_IDU2_EXE_InstructionPointer;
`endif
//--------------------------------------------------------

assign HDL_O = wCU2_FlipMem;

assign wCR2_TextureMappingEnabled = wCR2_ControlRegister[ `CR_EN_TEXTURE ];

//--------------------------------------------------------
//Control Unit Instance
	ControlUnit CU
	(
	   .Clock(Clock), 
		.Reset(Reset), 
		.oFlipMemEnabled(                   wCU2_FlipMemEnabled            ),
		.oFlipMem(                          wCU2_FlipMem                   ),
		.iControlRegister(                  wCR2_ControlRegister           ),
		//.oRamBusOwner(                      RamBusOwner                    ),
		.oGFUEnable(                        wCU2_GEO__GeometryFetchEnable  ),
		.iTriggerAABBIURequest(             wGEO2_CU__RequestAABBIU        ),
		.iTriggerBIURequest(                wGEO2_CU__RequestBIU           ),
		.iTriggertTCCRequest(               wGEO2_CU__RequestTCC           ),
		.oUCodeEnable(                      wCU2__ExecuteMicroCode         ),
		.oCodeInstructioPointer(           InitialCodeAddress             ),
		.iUCodeDone(                        wCU2__MicrocodeExecutionDone   ),
		.iIODone(                           wIO2__Done                     ),
		.oIOWritePixel(                     wCU2_IO__WritePixel            ),
		.iUCodeReturnValue(                 wIFU2__MicroCodeReturnValue    ),
		.iGEOSync(                          wGEO2_CU__Sync                 ),
		.iTFFDone(                          wGEO2_CU__TFFDone              ),
		.oTriggerTFF(                       wCU2_GEO__TriggerTFF           ),
		.MST_I(                             MST_I                          ),
		.oSetCurrentPitch(                  wCU2_GEO__SetPitch             ),
		.iGFUDone(                          wGEO2_CU__GeometryUnitDone     ),
		.iRenderEnable(                     RENDREN_I                      ),
		.iSceneTraverseComplete(            STDONE_I                       ),
		.oResultCommited(                   RCOMMIT_O                      ),
		.iHostDataAvailable(                HDA_I									 ),
		.iHostAckDataRead(                  HDLACK_I                       ),

		
		`ifdef DEBUG
		.iDebug_CoreID( iDebug_CoreID ),
		`endif
		.oDone(                             DONE_O                         )
		
	);
	
	

	
//--------------------------------------------------------	

//assign w2MEM_FlipMemory =  (wCU2__ExecuteMicroCode | wCU2_FlipMem ) & wCU2_FlipMemEnabled;
assign w2MEM_FlipMemory =  wCU2_FlipMem  & wCU2_FlipMemEnabled;
MemoryUnit MEM
(
.Clock(Clock), 
.Reset(Reset),

.iFlipMemory( w2MEM_FlipMemory ),

//Data Bus to/from EXE
.iDataReadAddress1_EXE(       wEXE_2__MEM_DataReadAddress0        ),
.iDataReadAddress2_EXE(       wEXE_2__MEM_DataReadAddress1        ),
.oData1_EXE(                  wMEM_2__EXE_DataRead0               ),
.oData2_EXE(                  wMEM_2__EXE_DataRead1               ),
.iDataWriteEnable_EXE(        wEXE_2__DataWriteEnable          ),
.iDataWriteAddress_EXE(       wEXE_2__MEM_wDataWriteAddress        ),
.iData_EXE(                   wEXE_2__MEM_WriteData          ),

//Data Bus to/from IO

.iDataReadAddress1_IO(       wIO_2_MEM__DataReadAddress0        ),
.iDataReadAddress2_IO(       wIO_2_MEM__DataReadAddress1        ),
.oData1_IO(                  wMEM_2__IO_DataRead0               ),
.oData2_IO(                  wMEM_2__IO_DataRead1               ),
.iDataWriteEnable_IO(        wIO2_MEM__DataWriteEnable          ),
.iDataWriteAddress_IO(       wIO2_MEM__DataWriteAddress        ),
.iData_IO(                   wIO2_MEM__Bus          ),

`ifdef DEBUG
.iDebug_CoreID( iDebug_CoreID ),
`endif


//Instruction Bus
.iInstructionReadAddress1(  wInstructionPointer1             ),
.iInstructionReadAddress2(  wInstructionPointer2             ),
.oInstruction1(             wEncodedInstruction1             ),
.oInstruction2(             wEncodedInstruction2             ),
.iInstructionWriteEnable(  wIO2_MEM_InstructionWriteEnable ), 
.iInstructionWriteAddress( wIO2_MEM__InstructionWriteAddr  ),
.iInstruction(             wIO2_MEM__ExternalInstruction   ),
.iControlRegister(         CREG_I                          ),
.oControlRegister(         wCR2_ControlRegister            )

);

////--------------------------------------------------------
  

ExecutionUnit EXE
(

.Clock( Clock),
.Reset( Reset ),
.iInitialCodeAddress(    InitialCodeAddress     ), 
.iInstruction1(          wEncodedInstruction1      ),
.iInstruction2(          wEncodedInstruction2      ),
.oInstructionPointer1(   wInstructionPointer1    ),
.oInstructionPointer2(   wInstructionPointer2    ),
.iDataRead0(             wMEM_2__EXE_DataRead0             ), 
.iDataRead1(             wMEM_2__EXE_DataRead1             ), 				
.iTrigger(               wCU2__ExecuteMicroCode ),
.oDataReadAddress0( wEXE_2__MEM_DataReadAddress0 ),
.oDataReadAddress1( wEXE_2__MEM_DataReadAddress1 ),
.oDataWriteEnable(  wEXE_2__DataWriteEnable  ),
.oDataWriteAddress( wEXE_2__MEM_wDataWriteAddress      ),
.oDataBus(          wEXE_2__MEM_WriteData          ), 
.oReturnCode(       wIFU2__MicroCodeReturnValue ),
/**************/
.oOMEMWriteAddress(   wEXE_2__IO_WriteAddress ),
.oOMEMWriteData(      wEXE_2__IO_WriteData    ),
.oOMEMWriteEnable(  wEXE_2__IO_OMEMWriteEnable ),

.oTMEMReadAddress(   wEXE_2__IO_TMEMAddress   ),
.iTMEMReadData(      wIO_2_EXE__TMEMData      ),
.iTMEMDataAvailable( wIO_2_EXE__DataAvailable ),
.oTMEMDataRequest(   wEXE_2_IO__DataRequest   ),
/**************/
`ifdef DEBUG
.iDebug_CoreID( iDebug_CoreID ),
`endif
.oDone(             wCU2__MicrocodeExecutionDone )

);

////--------------------------------------------------------


assign TGA_O = (wGEO2__RequestingTextures) ? 2'b1: 2'b0;
//---------------------------------------------------------------------------------------------------

//assign wEXE_2__MEM_DataReadAddress1 = (wCU2_IO__WritePixel == 0) ?  wUCODE_RAMReadAddress1 : wIO_2_MEM__DataReadAddress1;
assign w2IO__EnableWBMaster = (wCU2_IO__WritePixel == 0 ) ? wGEO2_IO__EnableWBMaster : wCU2_IO__WritePixel;
assign w2IO__AddrIsImm       = 0;//(wCU2_IO__WritePixel == 0 ) ? wGEO2_IO__AddrIsImm       : 1'b0;
assign w2IO__AddressOffset   = 0;//(wCU2_IO__WritePixel == 0 ) ? wGEO2_IO__AddressOffset   : 32'b0;
assign w2IO__Adr_O_Pointer      = (wCU2_IO__WritePixel == 0 ) ? wGEO2_IO__Adr_O_Pointer : `OREG_ADDR_O;
//assign w2IO__Adr_O_Pointer      = (wCU2_IO__WritePixel == 0 ) ? wGEO2_IO__Adr_O_Pointer : `CREG_PIXEL_2D_INITIAL_POSITION; 

wire w2IO_MasterCycleType;
assign w2IO_MasterCycleType = (wCU2_IO__WritePixel) ? `WB_SIMPLE_WRITE_CYCLE : `WB_SIMPLE_READ_CYCLE;



assign w2IO__SetAddress = (wCU2_IO__WritePixel == 0 )? wGEO2_IO__SetAddress : wCU2_GEO__SetPitch;


IO_Unit IO
(
 .Clock(               Clock                            ),
 .Reset(               Reset                            ),
 .iEnable(           1'b0 ),// w2IO__EnableWBMaster              ),
 .iBusCyc_Type(         w2IO_MasterCycleType            ),      
  
 .iStore(              1'b1),//w2IO__Store                      ),
 .iAdr_DataWriteBack(    w2IO__DataWriteAddress         ),
 .iAdr_O_Set(      w2IO__SetAddress                     ),
 .iAdr_O_Imm(       w2IO__AddressOffset                 ),
 .iAdr_O_Type(      w2IO__AddrIsImm                     ),
 .iAdr_O_Pointer(  w2IO__Adr_O_Pointer                  ),
 .iReadDataBus(        wMEM_2__IO_DataRead0                       ), 
 .iReadDataBus2(        wMEM_2__IO_DataRead1                       ), 
 .iDat_O_Pointer(     `OREG_PIXEL_COLOR                 ),
 
 
 .oDataReadAddress(    wIO_2_MEM__DataReadAddress0      ),
 .oDataReadAddress2(   wIO_2_MEM__DataReadAddress1       ),
 .oDataWriteAddress(   wIO2_MEM__DataWriteAddress    ),
 .oDataBus(       	  wIO2_MEM__Bus                 ),
 .oInstructionBus(     wIO2_MEM__ExternalInstruction    ),
 
 .oDataWriteEnable(         wIO2_MEM__DataWriteEnable    ),
 .oData(                    wIO2_MEM__Data                       ),
 .oInstructionWriteEnable(  wIO2_MEM_InstructionWriteEnable ),
 .oInstructionWriteAddress( wIO2_MEM__InstructionWriteAddr ),
 .iWriteBack_Set( w2IO_WriteBack_Set ),
 .oBusy(                      wIO_Busy                  ),
 .oDone(               wIO2__Done                       ),
 /**********/
 .iOMEM_WriteAddress(   wEXE_2__IO_WriteAddress         ),
 .iOMEM_WriteData(      wEXE_2__IO_WriteData            ),
 .iOMEM_WriteEnable(    wEXE_2__IO_OMEMWriteEnable    ),
 .OMEM_DAT_O( OMEM_DAT_O ),
 .OMEM_ADR_O( OMEM_ADR_O ),
 .OMEM_WE_O( OMEM_WE_O ),
 
 
 .oTMEMReadData(      wIO_2_EXE__TMEMData      ),
 .iTMEMDataRequest(   wEXE_2_IO__DataRequest   ),
 .iTMEMReadAddress(   wEXE_2__IO_TMEMAddress   ),	
 .oTMEMDataAvailable( wIO_2_EXE__DataAvailable ), 

.TMEM_ACK_I( TMEM_ACK_I ),
.TMEM_DAT_I( TMEM_DAT_I ), 
.TMEM_ADR_O( TMEM_ADR_O ),
.TMEM_WE_O(  TMEM_WE_O  ),
.TMEM_STB_O( TMEM_STB_O ),
.TMEM_CYC_O( TMEM_CYC_O ),
.TMEM_GNT_I( TMEM_GNT_I ),

 /**********/
 .MST_I( MST_I ),
  //Wish Bone Interface
.DAT_I( DAT_I ),
.DAT_O( DAT_O ),
.ACK_I( ACK_I & GNT_I ),
.ACK_O( ACK_O ),
.ADR_O( ADR_O ),
.ADR_I( ADR_I ),
.WE_O(  WE_O  ),
.WE_I(  WE_I  ),
.STB_O( STB_O ),
.STB_I( STB_I ),
.CYC_O( CYC_O ),
.TGA_I( TGA_I ),
.CYC_I( CYC_I ),
.GNT_I( GNT_I ),
.TGC_O( TGC_O )


);
//---------------------------------------------------------------------------------------------------
endmodule
