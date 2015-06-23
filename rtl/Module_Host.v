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


/*******************************************************************************
Module Description:

WIP

*******************************************************************************/



`define MAX_VERTEX_IN_FRAME      `WIDTH'd7 // WAS 8'd6
`define TAG_INSTRUCTION_ADDRESS_TYPE 2'b01
`define TAG_DATA_ADDRESS_TYPE        2'b10
`define SELECT_INST_MEM              3'b00
`define SELECT_SCENE_MEM             3'b01
`define SELECT_GEO_MEM               3'b10


`define HOST_IDLE                       0
`define HOST_WRITE_INSTRUCTION          1
`define HOST_WAIT_INSTRUCTION           2
`define HOST_WRITE_SCENE_PARAMS         3
`define HOST_WAIT_SCENE_PARAMS          4
`define HOST_PREPARE_CORE_CONFIG        5
`define HOST_UNICAST_CORE_CONFIG        6
`define HOST_WAIT_CORE_CONFIG           7
`define HOST_PREPARE_NEXT_CORE_CONFIG   8
`define HOST_WAIT_DATA_READ_CONFIRMATION       10
`define HOST_BROADCAST_NEXT_VERTEX   11
`define HOST_WAIT_FOR_VERTEX    12
`define HOST_INITIAL_SCENE_PARAMS_STAGE 13
`define HOST_PREPARE_FOR_GEO_REQUESTS   14
`define HOST_ACK_GEO_REQUEST            15
`define HOST_GET_PRIMITIVE_COUNT    16
`define HOST_LAST_PRIMITIVE_REACHED 17
`define HOST_GPU_EXECUTION_DONE 18

//---------------------------------------------------------------
module Module_Host
(
	input wire Clock,
	input wire Reset,
	input wire iEnable,
	input wire iHostDataReadConfirmed,
	input wire [`WB_WIDTH-1:0] iMemorySize,
	input wire [`WB_WIDTH-1:0] iPrimitiveCount,
	
	//To Memory
	output wire [`WB_WIDTH-1:0] oReadAddress,
	input wire [`WB_WIDTH-1:0]  iReadData,
	input wire iGPUCommitedResults,
	
	//To Hub/Switch
	output wire [`MAX_CORES-1:0]     oCoreSelectMask,
	output reg [2:0]                 oMemSelect,
	output wire [`WB_WIDTH-1:0]      DAT_O,
	output wire [`WB_WIDTH-1:0]      ADR_O,
	output reg[1:0]                  TGA_O,
	output reg[`MAX_CORES-1:0]       RENDREN_O,
	output wire                      CYC_O,
	output wire                      STB_O,
	output reg                       MST_O,
	output wire                      WE_O,
	input  wire  							GRDY_I,	//This means all the cores are done rading the primitive we send
   output reg                       GACK_O,	//We set this to ACK that the cored read the primitive
	output wire                       STDONE_O,
	output reg                       oHostDataAvailable,
	input wire                       iGPUDone,
	`ifndef NO_DISPLAY_STATS
	input wire [`WIDTH-1:0] iDebugWidth,
	`endif
	input wire                       ACK_I
);
//---------------------------------------------------------------
wire wLastPrimitive;
assign wLastPrimitive = (wVertexCount >= iPrimitiveCount) ? 1'b1 : 1'b0;
assign STDONE_O = wLastPrimitive;

wire  wWBMDone;
reg rWBMEnable,rWBMReset,rCoreBroadCast;
reg [`WB_WIDTH-1:0] rInitiaReadAddr;
wire [`MAX_CORES-1:0] wCoreSelect;
wire wLastValidReadAddress;
wire [`WB_WIDTH-1:0] wWriteAddress;
wire [`WIDTH-1:0] wVertexCount;
reg [`WB_WIDTH-1:0] rInitialWriteAddress;
reg rSetWriteAddr;
reg rIncCoreSelect,rResetVertexCount;
//--------------------------------------------------------

assign WE_O = MST_O;

assign oCoreSelectMask = 
	(rCoreBroadCast) ? `SELECT_ALL_CORES : wCoreSelect;
	
assign wLastValidReadAddress = 
	(oReadAddress >= iMemorySize) ? 1'b1 : 1'b0; 

wire wLastParameter;
assign wLastParameter = (oReadAddress >= 32'h12) ? 1'b1 : 1'b0;
//--------------------------------------------------------
UPCOUNTER_POSEDGE # (`WB_WIDTH ) UPWADDR
	(
	.Clock(  Clock                   ), 
	.Reset(   Reset | rSetWriteAddr  ),
	.Enable(  iEnable & wWBMDone     ),
	.Initial( rInitialWriteAddress   ),
	.Q(       wWriteAddress          )
	);


UPCOUNTER_POSEDGE # ( 32 ) PRIMCOUNT
	(
	.Clock(  Clock                   ), 
	.Reset(   Reset | rResetVertexCount  ),
	.Enable(  iEnable & wWBMDone     ),
	.Initial( `WIDTH'b1   ),	
	.Q(       wVertexCount          )
	);
//--------------------------------------------------------
CIRCULAR_SHIFTLEFT_POSEDGE_EX # (`MAX_CORES ) SHF1
( 
	.Clock(    Clock             ), 
	.Reset(    Reset             ),
	.Initial( `MAX_CORES'b1      ), 
	.Enable(   rIncCoreSelect    ),
	.O(        wCoreSelect       )
);
//--------------------------------------------------------
wire wShortCycle;
//For instruction we send 2 packets per cycle
//for the other we send 3 packets per cycle
assign wShortCycle = (oMemSelect == `SELECT_INST_MEM) ? 1'b1 : 1'b0;

WBMaster WBM
(
.Clock(            Clock             ),
.Reset(            Reset | rWBMReset ),
.iEnable(          rWBMEnable        ),
.iInitialReadAddr( rInitiaReadAddr   ),
.iWriteAddr(       wWriteAddress     ),
.oReadAddress(     oReadAddress      ),
.iReadData(        iReadData         ),
.iShortFlow(        wShortCycle     ),	
														
	
.STB_O( STB_O ),
.ACK_I( ACK_I ),
.CYC_O( CYC_O ),
.DAT_O( DAT_O ),
.ADR_O( ADR_O ),
.oDone( wWBMDone )
);

//--------------------------------------------------------
// Current State Logic //
reg [7:0] 			rHostCurrentState,rHostNextState;
always @(posedge Clock or posedge Reset)
begin
     if( Reset!=1 )
        rHostCurrentState <= rHostNextState;
	  else
		  rHostCurrentState <= `HOST_IDLE;		
end
//--------------------------------------------------------

reg [63:0] i;
reg [63:0] RenderedPixels;
wire wLastVertexInFrame;
assign wLastVertexInFrame = 
(wVertexCount % `MAX_VERTEX_IN_FRAME == 1'b0 ) ? 1'b1 : 1'b0;

// WAS ((wVertexCount % `MAX_VERTEX_IN_FRAME) == 1'b0 && wVertexCount != 0) ? 1'b1 : 1'b0;

reg [31:0] StartTime;

// Host Finite State Machine //
always @( * )
	begin
		
		case (rHostCurrentState)
		//----------------------------------------
		//Wait for reset sequence to complete,
		//Or until we are enabled
		`HOST_IDLE:
		begin
		RenderedPixels = 0;
		
			rWBMEnable            = 0;
		   rInitiaReadAddr       = 1;	//Start reading from 1, because 0 is the size
			rWBMReset             = 0;
			oMemSelect            = 0;
			TGA_O                 = 0;
			MST_O	                = 0;
			rInitialWriteAddress  = 0;									
         rSetWriteAddr         = 0;
			rCoreBroadCast        = 0;
			rIncCoreSelect        = 0;
			RENDREN_O				 = 0;
			rResetVertexCount  = 0;
			GACK_O					 = 0;
			//STDONE_O					 = 0;
			oHostDataAvailable    = 0;
			
			if ( ~Reset & iEnable )
			begin
				$display("-I- HOST: Broadcasting User code to all Cores\n"); $fflush;
				rHostNextState = `HOST_WRITE_INSTRUCTION;
			end	
			else
				rHostNextState = `HOST_IDLE;
		end
		//----------------------------------------
		//Broadcast the instructions to all the cores
		`HOST_WRITE_INSTRUCTION:
		begin
		
			StartTime = $time;
			
			rWBMEnable            = 1;										//Enable Wish bone master
		   rInitiaReadAddr       = 1;										//Start reading from 1, because 0 is the size
			rWBMReset             = 0;										//No need to reset since we just came from reset
			oMemSelect            = `SELECT_INST_MEM;					//Start by sending the instructions
			TGA_O                 = `TAG_INSTRUCTION_ADDRESS_TYPE;
			MST_O	                = 1;
			rInitialWriteAddress  = 0;
         rSetWriteAddr         = 0;
			rCoreBroadCast        = 1;
			rIncCoreSelect        = 0;
			RENDREN_O				 = 0;
			rResetVertexCount  = 0;
			GACK_O					 = 0;
			//STDONE_O					 = 0;
			oHostDataAvailable    = 0;	
			
			rHostNextState = `HOST_WAIT_INSTRUCTION;
		end
		//----------------------------------------
		`HOST_WAIT_INSTRUCTION:
		begin
			rWBMEnable            = ~wWBMDone;
		   rInitiaReadAddr       = 0;
			rWBMReset             = 0;
			oMemSelect            = `SELECT_INST_MEM;
			TGA_O                 = `TAG_INSTRUCTION_ADDRESS_TYPE;
			MST_O	                = 1;
			rInitialWriteAddress  = 0;
         rSetWriteAddr         = 0;
			rCoreBroadCast        = 1;
			rIncCoreSelect        = 0;
			RENDREN_O				 = 0;
			rResetVertexCount  = 0;
			GACK_O					 = 0;	
			//STDONE_O					 = 0;
			oHostDataAvailable    = 0;
			
			if ( wWBMDone && ~wLastValidReadAddress )
				rHostNextState = `HOST_WRITE_INSTRUCTION;
			else if (wWBMDone && wLastValidReadAddress )
				rHostNextState = `HOST_INITIAL_SCENE_PARAMS_STAGE;
			else
				rHostNextState = `HOST_WAIT_INSTRUCTION;
		end
		//----------------------------------------
		/*
			Make sure to read-pointer points to the
			first memory address at te params memory
		*/
		`HOST_INITIAL_SCENE_PARAMS_STAGE:
		begin
			rWBMEnable            = 0;
		   rInitiaReadAddr       = 1;											//Start reading from 1, because 0 is the size
			rWBMReset             = 1;
			oMemSelect            = `SELECT_SCENE_MEM;						//We are reading from the scene memory
			TGA_O                 = `TAG_DATA_ADDRESS_TYPE;				//We will write to the DATA section of the core MEM
			MST_O	                = 1;											//Keep master signal in 1 for now
			rInitialWriteAddress  = 0;											//We start writing from address zero now
         rSetWriteAddr         = 1;											
			rCoreBroadCast        = 1;											//Set to zero to unicast, starting from core 0
			rIncCoreSelect        = 0;											//Set to unicast to the next core
			RENDREN_O				 = 0;
			rResetVertexCount  = 0;
			GACK_O					 = 0;	
			//STDONE_O					 = 0;
			oHostDataAvailable    = 0;
			
			$display("-I- HOST: Configuring Core Mask %b\n",oCoreSelectMask); $fflush;
			
			rHostNextState = `HOST_WRITE_SCENE_PARAMS;
		end
		
		//----------------------------------------
		//Broadcast the instructions to all the cores
		`HOST_WRITE_SCENE_PARAMS:
		begin
			rWBMEnable            = 1;
		   rInitiaReadAddr       = 0;
			rWBMReset             = 0;
			oMemSelect            = `SELECT_SCENE_MEM;
			TGA_O                 = `TAG_DATA_ADDRESS_TYPE;
			MST_O	                = 1;
			rInitialWriteAddress  = 0;
         rSetWriteAddr         = 0;
			rCoreBroadCast        = 1;
			rIncCoreSelect        = 0;
			RENDREN_O				 = 0;
			rResetVertexCount  = 0;
			GACK_O					 = 0;
			//STDONE_O					 = 0;
			oHostDataAvailable    = 0;
			
			rHostNextState = `HOST_WAIT_SCENE_PARAMS;
		end
		//----------------------------------------
		`HOST_WAIT_SCENE_PARAMS:
		begin
			rWBMEnable            = ~wWBMDone;
		   rInitiaReadAddr       = 0;
			rWBMReset             = 0;
			oMemSelect            = `SELECT_SCENE_MEM;
			TGA_O                 = `TAG_DATA_ADDRESS_TYPE;
			MST_O	                = 1;
			rInitialWriteAddress  = 0;
         rSetWriteAddr         = 0;
			rCoreBroadCast        = 1;
			rIncCoreSelect        = 0;
			RENDREN_O				 = 0;
			rResetVertexCount  = 0;
			GACK_O					 = 0;
			//STDONE_O					 = 0;
			oHostDataAvailable    = 0;
			
			if ( wWBMDone && ~wLastParameter )
				rHostNextState = `HOST_WRITE_SCENE_PARAMS;
			else if (wWBMDone && wLastParameter )
				rHostNextState = `HOST_PREPARE_CORE_CONFIG;
			else
				rHostNextState = `HOST_WAIT_SCENE_PARAMS;
		end
		//----------------------------------------
		/*
			This state set the read Write Address pointer to 
			CREG_PIXEL_2D_INITIAL_POSITION memory position,
			also selects the scene MEM from the external MEM
			MUX.
		*/
		`HOST_PREPARE_CORE_CONFIG:
		begin
			rWBMEnable            = 0;
		   rInitiaReadAddr       = 0;
			rWBMReset             = 0;
			oMemSelect            = `SELECT_SCENE_MEM;						//We are reading from the scene memory
			TGA_O                 = `TAG_DATA_ADDRESS_TYPE;				//We will write to the DATA section of the core MEM
			MST_O	                = 1;											//Keep master signal in 1 for now
			rInitialWriteAddress  = `CREG_PIXEL_2D_INITIAL_POSITION;	//The address from which to start wrting @ the cores
         rSetWriteAddr         = 1;											//Set to use the initial write address bellow
			rCoreBroadCast        = 0;											//Set to zero to unicast, starting from core 0
			rIncCoreSelect        = 0;											//Set to unicast to the next core
			RENDREN_O				 = 0;
			rResetVertexCount  = 0;
			GACK_O					 = 0;
			//STDONE_O					 = 0;
			oHostDataAvailable    = 0;
			
			
			rHostNextState = `HOST_UNICAST_CORE_CONFIG;
		end
		
		//----------------------------------------
		`HOST_UNICAST_CORE_CONFIG:
		begin
			rWBMEnable            = 1;
		   rInitiaReadAddr       = 0;
			rWBMReset             = 0;
			oMemSelect            = `SELECT_SCENE_MEM;
			TGA_O                 = `TAG_DATA_ADDRESS_TYPE;
			MST_O	                = 1;
			rInitialWriteAddress  = 0;
         rSetWriteAddr         = 0;
			rCoreBroadCast        = 0;
			rIncCoreSelect        = 0;
			RENDREN_O				 = 0;
			rResetVertexCount  = 0;
			GACK_O					 = 0;
			//STDONE_O					 = 0;
			oHostDataAvailable    = 0;
			
			rHostNextState = `HOST_WAIT_CORE_CONFIG;
		end
		//----------------------------------------
		`HOST_WAIT_CORE_CONFIG:
		begin
			rWBMEnable            = ~wWBMDone;
		   rInitiaReadAddr       = 0;
			rWBMReset             = 0;
			oMemSelect            = `SELECT_SCENE_MEM;
			TGA_O                 = `TAG_DATA_ADDRESS_TYPE;
			MST_O	                = 1;
			rInitialWriteAddress  = 0;
         rSetWriteAddr         = 0;
			rCoreBroadCast        = 0;
			rIncCoreSelect        = 0;
			RENDREN_O				 = 0;
			rResetVertexCount  = 0;
			GACK_O					 = 0;
			//STDONE_O					 = 0;
			oHostDataAvailable    = 0;
				
			if (wWBMDone && !(oReadAddress % 2))
				rHostNextState = `HOST_UNICAST_CORE_CONFIG;
			else if (wWBMDone && (oReadAddress % 2) )
				rHostNextState = `HOST_PREPARE_NEXT_CORE_CONFIG;
			else
				rHostNextState = `HOST_WAIT_CORE_CONFIG;
		
		end	
		//----------------------------------------
		/*
			Reset the WBM to tell it to start reading
			from address 0 at the Geometry memory.
		*/
		`HOST_PREPARE_NEXT_CORE_CONFIG:
		begin
			rWBMEnable            = 0;
		   rInitiaReadAddr       = 0;
			rWBMReset             = 0;
			oMemSelect            = `SELECT_GEO_MEM;
			TGA_O                 = `TAG_DATA_ADDRESS_TYPE;	
			MST_O	                = 0;											//The master signal goes to zero until request
			rInitialWriteAddress  = `CREG_PIXEL_2D_INITIAL_POSITION;	//Write starting from this location on the cores
         rSetWriteAddr         = 1;											//Set to use the initial write address bellow
			rCoreBroadCast        = 0;					
			rIncCoreSelect        = 1;											//Moving to configure the next core now
			RENDREN_O				 = 0;
			rResetVertexCount  = 0;
			GACK_O					 = 0;
			//STDONE_O					 = 0;
			oHostDataAvailable    = 0;
			
			if (wCoreSelect[`MAX_CORES-1] == 1)
				rHostNextState = `HOST_PREPARE_FOR_GEO_REQUESTS;
			else
				rHostNextState = `HOST_UNICAST_CORE_CONFIG;
		end
		//----------------------------------------
		/*
			Prepare the write address for the next primitive.
			
		*/
		`HOST_PREPARE_FOR_GEO_REQUESTS:
		begin
			rWBMEnable            = 0;								//Do not enable until we are resquested
		   rInitiaReadAddr       = 32'hA;							//Start reading from addr 0 @ GEO MEM
			rWBMReset             = 1;								//Tell WBM to start reading from the addr bellow
			oMemSelect            = `SELECT_GEO_MEM; 			//Use external GEO mem for reading
			TGA_O                 = `TAG_DATA_ADDRESS_TYPE;	//We write to the data MEM @ the cores
			MST_O	                = 0;								//The master signal goes to zero until request
			rInitialWriteAddress  = `CREG_V0;						//Write starting from this location on the cores
         rSetWriteAddr         = 1;								//Set to use the initial write address bellow
			rCoreBroadCast        = 1;								//From now on we only broadcast					
			rIncCoreSelect        = 0;								//Ignored during broadcasts	
			RENDREN_O				 = 0;
			rResetVertexCount  = 1;
			GACK_O					 = 0;
			//STDONE_O					 = 0;
			oHostDataAvailable    = 0;
			
			if (iGPUDone)
				rHostNextState = `HOST_GPU_EXECUTION_DONE;
			else
				rHostNextState = `HOST_BROADCAST_NEXT_VERTEX;
			
		end
		//----------------------------------------
		`HOST_ACK_GEO_REQUEST:
		begin
			rWBMEnable            = 0;								//Do not enable until we are resquested
		   rInitiaReadAddr       = 0;								//Ignored
			rWBMReset             = 0;								//Ignored
			oMemSelect            = `SELECT_GEO_MEM; 			//Use external GEO mem for reading
			TGA_O                 = `TAG_DATA_ADDRESS_TYPE;	//We write to the data MEM @ the cores
			MST_O	                = 0;								//The master signal goes to zero until request
			rInitialWriteAddress  = `CREG_V0;						//Write starting from this location on the cores
         rSetWriteAddr         = 1;								//Set to use the initial write address bellow
			rCoreBroadCast        = 1;								//From now on we only broadcast					
			rIncCoreSelect        = 0;								//Ignored during broadcasts	
			RENDREN_O				 = 0;
			rResetVertexCount  	= 0;
			GACK_O					 = 1;
			//STDONE_O					 = 0;
			oHostDataAvailable    = 0;
			
			
			rHostNextState = `HOST_BROADCAST_NEXT_VERTEX;
			
		end
		//----------------------------------------
		/*
			Send the next primitive to the HUB/SWITCH unit
			so that it gets broadcasted to all the cores
		*/
		`HOST_BROADCAST_NEXT_VERTEX:
		begin
			rWBMEnable            = 1;								//Start the Transmition						
		   rInitiaReadAddr       = 0;								
			rWBMReset             = 0;								
			oMemSelect            = `SELECT_GEO_MEM; 			
			TGA_O                 = `TAG_DATA_ADDRESS_TYPE;	
			MST_O	                = 1;								//Start the Transmition
			rInitialWriteAddress  = 0;				
         rSetWriteAddr         = 0;								
			rCoreBroadCast        = 1;								
			rIncCoreSelect        = 0;	
			RENDREN_O				 = `SELECT_ALL_CORES;
			rResetVertexCount  = 0;
			GACK_O					 = 0;
			//STDONE_O					 = 0;
			oHostDataAvailable    = 0;
			
			rHostNextState = `HOST_WAIT_FOR_VERTEX;			
			
		end
		//----------------------------------------
		`HOST_WAIT_FOR_VERTEX:
		begin
			rWBMEnable            = ~wWBMDone;						//Disable WBM when it is donw						
		   rInitiaReadAddr       = 0;								
			rWBMReset             = 0;								
			oMemSelect            = `SELECT_GEO_MEM; 			
			TGA_O                 = `TAG_DATA_ADDRESS_TYPE;	
			MST_O	                = 1;								//Start the Transmition
			rInitialWriteAddress  = 0;				
         rSetWriteAddr         = 0;								
			rCoreBroadCast        = 1;								
			rIncCoreSelect        = 0;
			RENDREN_O				 = `SELECT_ALL_CORES;
			rResetVertexCount  = 0;
			GACK_O					 = 0;
			//STDONE_O					 = 0;
			oHostDataAvailable    = 0;
			
			
			if (wWBMDone & ~wLastVertexInFrame )
				rHostNextState = `HOST_BROADCAST_NEXT_VERTEX;
			else if (wWBMDone & wLastVertexInFrame )
				rHostNextState = `HOST_GET_PRIMITIVE_COUNT;
			else
				rHostNextState = `HOST_WAIT_FOR_VERTEX;
				
				
			/*
			if (wWBMDone)
				rHostNextState = `HOST_WAIT_DATA_READ_CONFIRMATION;
			else
				rHostNextState = `HOST_WAIT_FOR_VERTEX;
				*/
		end
		//----------------------------------------
		`HOST_GET_PRIMITIVE_COUNT:
		begin
			rWBMEnable            = 0;						//Disable WBM when it is donw						
		   rInitiaReadAddr       = 0;								
			rWBMReset             = 0;								
			oMemSelect            = `SELECT_GEO_MEM; 			
			TGA_O                 = `TAG_DATA_ADDRESS_TYPE;	
			MST_O	                = 1;								//Start the Transmition
			rInitialWriteAddress  = 0;				
         rSetWriteAddr         = 0;								
			rCoreBroadCast        = 1;								
			rIncCoreSelect        = 0;
			RENDREN_O				 = `SELECT_ALL_CORES;
			rResetVertexCount  = 0;
			GACK_O					 = 0;
			//STDONE_O					 = 0;
			oHostDataAvailable    = 0;//1;
			
			if (wVertexCount >= iPrimitiveCount)
				rHostNextState = `HOST_LAST_PRIMITIVE_REACHED;
			else
				rHostNextState = `HOST_WAIT_DATA_READ_CONFIRMATION;
			
		end
		//----------------------------------------
		/*
			we wait until all the cores are ready for the next primitive, 
			this happens when the iHostDataReadConfirmed signal 
			gets asserted
		*/
		`HOST_WAIT_DATA_READ_CONFIRMATION:
		begin
			rWBMEnable            = 0;								//Do not enable until we are resquested
		   rInitiaReadAddr       = 0;								//Ignored
			rWBMReset             = 0;								//Continue from previous read address
			oMemSelect            = `SELECT_GEO_MEM; 			//Use external GEO mem for reading
			TGA_O                 = `TAG_DATA_ADDRESS_TYPE;	//We write to the data MEM @ the cores
			MST_O	                = 0;								//The master signal goes to zero until request
			rInitialWriteAddress  = `CREG_V0;						//Write starting from this location on the cores
         rSetWriteAddr         = 1;								//Set to use the initial write address bellow
			rCoreBroadCast        = 1;								//From now on we only broadcast					
			rIncCoreSelect        = 0;								//Ignored during broadcasts	
			RENDREN_O				 = `SELECT_ALL_CORES;
			rResetVertexCount  = 0;
			GACK_O					 = 0;
			//STDONE_O					 = 0;
			oHostDataAvailable    = 1;
			
			if ( iHostDataReadConfirmed )
				rHostNextState = `HOST_ACK_GEO_REQUEST;
			else
				rHostNextState = `HOST_WAIT_DATA_READ_CONFIRMATION;
		end
		//----------------------------------------
		`HOST_LAST_PRIMITIVE_REACHED:
		begin
			rWBMEnable            = 0;								//Disable WBM when it is donw						
		   rInitiaReadAddr       = 32'hA;							//Reset primitive counter to first primitive						
			rWBMReset             = 1;								//Reset primitive counter to first primitive		
			oMemSelect            = `SELECT_GEO_MEM; 			
			TGA_O                 = `TAG_DATA_ADDRESS_TYPE;	
			MST_O	                = 1;								
			rInitialWriteAddress  = 0;				
         rSetWriteAddr         = 0;								
			rCoreBroadCast        = 1;								
			rIncCoreSelect        = 0;
			RENDREN_O				 = `SELECT_ALL_CORES;
			rResetVertexCount     = 0;							//Reset the vertex count to zero
			GACK_O					 = 0;
			//STDONE_O					 = 1;
			oHostDataAvailable    = 0;			

			
			
			if (iGPUCommitedResults)
			begin
			
			`ifndef NO_DISPLAY_STATS
			for (i = 0; i < `MAX_CORES; i = i + 1)
			begin
				$write(".");
			end
			RenderedPixels = RenderedPixels + `MAX_CORES;
			if ( RenderedPixels % iDebugWidth == 0)
				$write("]%d\n[",RenderedPixels / iDebugWidth);
			`endif
			
				rHostNextState = `HOST_PREPARE_FOR_GEO_REQUESTS;
			end	
			else
				rHostNextState = `HOST_LAST_PRIMITIVE_REACHED;
		end
		//----------------------------------------
		`HOST_GPU_EXECUTION_DONE:
		begin
			$display("THEIA Execution done in %dns\n",$time-StartTime);
		  rWBMEnable            = 0;						
		   rInitiaReadAddr       = 0;								
			rWBMReset             = 0;								
			oMemSelect            = 0; 			
			TGA_O                 = 0;	
			MST_O	                = 0;								
			rInitialWriteAddress  = 0;				
         rSetWriteAddr         = 0;								
			rCoreBroadCast        = 0;								
			rIncCoreSelect        = 0;
			RENDREN_O				 = 0;
			rResetVertexCount  = 0;
			GACK_O					 = 0;
			//STDONE_O					 = 0;
			oHostDataAvailable    = 0;
			
			rHostNextState = `HOST_GPU_EXECUTION_DONE;
		end
		//----------------------------------------
		default:
		begin
		
			rWBMEnable            = 0;						
		   rInitiaReadAddr       = 0;								
			rWBMReset             = 0;								
			oMemSelect            = 0; 			
			TGA_O                 = 0;	
			MST_O	                = 0;								
			rInitialWriteAddress  = 0;				
         rSetWriteAddr         = 0;								
			rCoreBroadCast        = 0;								
			rIncCoreSelect        = 0;
			RENDREN_O				 = 0;
			rResetVertexCount  = 0;
			GACK_O					 = 0;
			//STDONE_O					 = 0;
			oHostDataAvailable    = 0;
			
			rHostNextState = `HOST_IDLE;
		end
		//----------------------------------------
		endcase
end		

endmodule
