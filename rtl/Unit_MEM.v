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
/*
The memory unit has all the memory related modules for THEIA.
There a 3 memories in the core: 
DMEM: The data memory, it is a R/W dual channel RAM, stores the data locations.
IMEM: The instruction memory, R/W dual channel RAM, stores user shaders.
IROM: RO instruction memory, stores default shaders and other internal code.
I use two ROMs with the same data, so that simulates dual channel. 
This unit also has a Control register.
*/
`define USER_CODE_ENABLED 2
//-------------------------------------------------------------------
module MemoryUnit
(
input wire                              Clock,
input wire                              Reset,
input wire	                            iFlipMemory,

//Data bus for EXE Unit
input wire                              iDataWriteEnable_EXE,
input wire[`DATA_ADDRESS_WIDTH-1:0]     iDataReadAddress1_EXE,
output wire[`DATA_ROW_WIDTH-1:0]        oData1_EXE,
input wire[`DATA_ADDRESS_WIDTH-1:0]     iDataReadAddress2_EXE,
output wire[`DATA_ROW_WIDTH-1:0]        oData2_EXE,
input wire[`DATA_ADDRESS_WIDTH-1:0]     iDataWriteAddress_EXE,
input wire[`DATA_ROW_WIDTH-1:0]         iData_EXE,

//Data bus for IO Unit
input wire                              iDataWriteEnable_IO,
input wire[`DATA_ADDRESS_WIDTH-1:0]     iDataReadAddress1_IO,
output wire[`DATA_ROW_WIDTH-1:0]        oData1_IO,
input wire[`DATA_ADDRESS_WIDTH-1:0]     iDataReadAddress2_IO,
output wire[`DATA_ROW_WIDTH-1:0]        oData2_IO,
input wire[`DATA_ADDRESS_WIDTH-1:0]     iDataWriteAddress_IO,
input wire[`DATA_ROW_WIDTH-1:0]         iData_IO,

//Instruction bus
input wire                              iInstructionWriteEnable,
input  wire [`ROM_ADDRESS_WIDTH-1:0]    iInstructionReadAddress1,
input  wire [`ROM_ADDRESS_WIDTH-1:0]    iInstructionReadAddress2,
input wire [`ROM_ADDRESS_WIDTH-1:0]     iInstructionWriteAddress,
input wire [`INSTRUCTION_WIDTH-1:0]     iInstruction,
output wire [`INSTRUCTION_WIDTH-1:0]    oInstruction1,
output wire [`INSTRUCTION_WIDTH-1:0]    oInstruction2,

`ifdef DEBUG
input wire [`MAX_CORES-1:0]            iDebug_CoreID,
`endif


//Control Register
input wire[15:0]	                      iControlRegister,
output wire[15:0]                       oControlRegister


);

wire [`ROM_ADDRESS_WIDTH-1:0] wROMInstructionAddress,wRAMInstructionAddress;
wire [`INSTRUCTION_WIDTH-1:0] wIMEM2_IMUX__DataOut1,wIMEM2_IMUX__DataOut2,
wIROM2_IMUX__DataOut1,wIROM2_IMUX__DataOut2;
wire wFlipSelect;

wire wInstructionSelector,wInstructionSelector2;
FFD_POSEDGE_SYNCRONOUS_RESET # ( 1 ) FFD1
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable( 1'b1 ),
	.D( iInstructionReadAddress1[`ROM_ADDRESS_WIDTH-1]  ),
	.Q( wInstructionSelector )
);

FFD_POSEDGE_SYNCRONOUS_RESET # ( 1 ) FFD2
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable( 1'b1 ),
	.D( iInstructionReadAddress2[`ROM_ADDRESS_WIDTH-1]  ),
	.Q( wInstructionSelector2 )
);

assign oInstruction1 = (wInstructionSelector == 1) ? 
	wIMEM2_IMUX__DataOut1 : wIROM2_IMUX__DataOut1;


assign oInstruction2 = (wInstructionSelector2 == 1) ? 
	wIMEM2_IMUX__DataOut2 : wIROM2_IMUX__DataOut2;	  
//-------------------------------------------------------------------

wire wDataWriteEnable_RMEM,wDataWriteEnable_SMEM,wDataWriteEnable_XMEM;
wire [`DATA_ROW_WIDTH-1:0] wData_SMEM1,wData_SMEM2;
wire [`DATA_ROW_WIDTH-1:0] wData_RMEM1,wData_RMEM2,wData_IMEM1,wData_IMEM2,wData_XMEM1,wData_XMEM2;
wire [`DATA_ROW_WIDTH-1:0] wIOData_SMEM1,wIOData_SMEM2;//,wData_OMEM1,wData_OMEM2;

/*******************************************************
The Data memory is divided into several memory banks.
Each Bank has different characteristics:

* IO MEM: Input Registers, Written by IO, Read by EXE.
* SWAP MEM: Swap registers, while IO reads/write values, 
  EXE reads/write values.
* C1-C7, R1- R12: General purpose registers, 
  EXE can R/W, IO can not see these sections of the memory
* OREG*: Output registers written by EXE, Read by IO.

Whenever an input address is received, this imput address
is divided in a bank selector and offset in the following way:

  __________________________
  | b6 b5 | b4 b3 b2 b1 b0 |
  
The bits b4 .. b0 are the LSB of the address, this give the
position relative to the bank

The bits b6 and b5 give the actual Bank to select.
Please see aDefinitions.v for a description of each 
register location.    

       0____________________ 
        |      IO MEM      |
        |                  |
        |                  | b6b5 = 00
      32|__________________|
        |     SWAP MEM     |
        |                  | b6b5 = 01
        |                  | 
      64|__________________|
        |     C1 - C7      |
        |     R1 - R12     | b6b5 = 10
        |                  | 
      96|__________________|	
        |     CREG*        |
        |                  | b6b5 = 11
        |                  | 
        |__________________|		
		  
		
*******************************************************/



MUXFULLPARALELL_2SEL_GENERIC # ( `DATA_ROW_WIDTH ) MUX1
 (
 .Sel( iDataReadAddress1_EXE[6:5] ),
 .I1( wData_IMEM1                ), //IO MEM
 .I2( wData_SMEM1                ), //SWAP MEM
 .I3( wData_RMEM1                ), //R*, C*
 .I4( wData_XMEM1                ), //CREG*
 .O1( oData1_EXE                 )
 );


MUXFULLPARALELL_2SEL_GENERIC # ( `DATA_ROW_WIDTH ) MUX2
 (
 .Sel( iDataReadAddress2_EXE[6:5] ),
 .I1( wData_IMEM2                ), //IO MEM
 .I2( wData_SMEM2                ), //SWAP MEM
 .I3( wData_RMEM2                ), //R*, C*
 .I4( wData_XMEM2                ), //CREG*
 .O1( oData2_EXE                 )
 );

assign wDataWriteEnable_SMEM = ( iDataWriteAddress_EXE[6:5] == 2'b01 && iDataWriteEnable_EXE ); //Enable WE for SMEM if bank == 01
assign wDataWriteEnable_RMEM = ( iDataWriteAddress_EXE[6:5] == 2'b10 && iDataWriteEnable_EXE); //Enable WE for RMEM if bank == 10
assign wDataWriteEnable_XMEM = ( iDataWriteAddress_EXE[6:5] == 2'b11 && iDataWriteEnable_EXE); //Enable WE for RMEM if bank == 11


//Input Registers, Written by IO, Read by EXE
RAM_DUAL_READ_PORT  # (`DATA_ROW_WIDTH,5,/*42*/32) IMEM //16 here is enough, I hate small devices!
(
	.Clock( Clock ),
	.iWriteEnable(  iDataWriteEnable_IO        ), //Only IO can write into this bank
	.iReadAddress0( iDataReadAddress1_EXE[4:0] ), //EXE read address channel 1
	.iReadAddress1( iDataReadAddress2_EXE[4:0] ), //EXE read address channel 2
	.iWriteAddress( iDataWriteAddress_IO[4:0]  ), //Only IO can write into this bank
	.iDataIn( iData_IO ),
	.oDataOut0( wData_IMEM1 ),
	.oDataOut1( wData_IMEM2 )
);

//Swap registers, while IO reads/write values, EXE reads/write values
//the pointers get filped in the next iteration

SWAP_MEM  # (`DATA_ROW_WIDTH,5,32) SMEM
(
	.Clock( Clock ),
	.iSelect( wFlipSelect ),
	
	.iWriteEnableA( wDataWriteEnable_SMEM ),
	.iReadAddressA0( iDataReadAddress1_EXE[4:0] ),
	.iReadAddressA1( iDataReadAddress2_EXE[4:0] ),
	.iWriteAddressA( iDataWriteAddress_EXE[4:0] ),
	.iDataInA( iData_EXE ),
	.oDataOutA0( wData_SMEM1 ),
	.oDataOutA1( wData_SMEM2 ),
	
	.iWriteEnableB( iDataWriteEnable_IO ),
	.iReadAddressB0( iDataReadAddress1_IO ),
	.iReadAddressB1( iDataReadAddress2_IO ),
	.iWriteAddressB( iDataWriteAddress_IO ),
	.iDataInB( iData_IO )
//	.oDataOutB0( wIOData_SMEM1 ),
//	.oDataOutB1( wIOData_SMEM2 )
	
); 

//General purpose registers, EXE can R/W, IO can not see these sections
//of the memory
RAM_DUAL_READ_PORT  # (`DATA_ROW_WIDTH,5,32) RMEM //Ok so we have fewer Registers then...
(
	.Clock( Clock ),
	.iWriteEnable( wDataWriteEnable_RMEM ),
	.iReadAddress0( iDataReadAddress1_EXE[4:0] ),
	.iReadAddress1( iDataReadAddress2_EXE[4:0] ),
	.iWriteAddress( iDataWriteAddress_EXE[4:0] ),
	.iDataIn( iData_EXE ),
	.oDataOut0( wData_RMEM1 ),
	.oDataOut1( wData_RMEM2 )
);

RAM_DUAL_READ_PORT  # (`DATA_ROW_WIDTH,5,32) XMEM //Ok so we have fewer Registers then...
(
	.Clock( Clock ),
	.iWriteEnable( wDataWriteEnable_XMEM ),
	.iReadAddress0( iDataReadAddress1_EXE[4:0] ),
	.iReadAddress1( iDataReadAddress2_EXE[4:0] ),
	.iWriteAddress( iDataWriteAddress_EXE[4:0] ),
	.iDataIn( iData_EXE ),
	.oDataOut0( wData_XMEM1 ),
	.oDataOut1( wData_XMEM2 )
);


UPCOUNTER_POSEDGE # (1) UPC1
(
.Clock(Clock),
.Reset( Reset ),
.Initial(1'b0),
.Enable(iFlipMemory),
.Q(wFlipSelect)
);



//-------------------------------------------------------------------
/*
Instruction memory.
*/

// ROM_ADDRESS_WIDTH exceds the array size it may get trimmed...
RAM_DUAL_READ_PORT  # (`INSTRUCTION_WIDTH,`ROM_ADDRESS_WIDTH,/*512*/128) INST_MEM //Only 128 instructions :( well this is for the user anyway
(
	.Clock( Clock ),
	.iWriteEnable( iInstructionWriteEnable ),
	.iReadAddress0( {1'b0,iInstructionReadAddress1[`ROM_ADDRESS_WIDTH-2:0]} ),
	.iReadAddress1( {1'b0,iInstructionReadAddress2[`ROM_ADDRESS_WIDTH-2:0]} ),
	.iWriteAddress( iInstructionWriteAddress ),
	.iDataIn( iInstruction ),
	.oDataOut0( wIMEM2_IMUX__DataOut1 ),
	.oDataOut1( wIMEM2_IMUX__DataOut2 )
	
);
//-------------------------------------------------------------------
/*
 Default code stored in ROM.
*/
wire [`INSTRUCTION_WIDTH-1:0] wRomDelay1,wRomDelay2;
//In real world ROM will take at least 1 clock cycle,
//since ROMs are not syhtethizable, I won't hurt to put
//this delay

FFD_POSEDGE_SYNCRONOUS_RESET # ( `INSTRUCTION_WIDTH ) FFDA
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(wRomDelay1),
	.Q(wIROM2_IMUX__DataOut1 )
);


FFD_POSEDGE_SYNCRONOUS_RESET # ( `INSTRUCTION_WIDTH ) FFDB
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(wRomDelay2),
	.Q(wIROM2_IMUX__DataOut2 )
);

//The reason I put two ROMs is because I need to read 2 different Instruction 
//addresses at the same time (branch-taken and branch-not-taken) and not sure
//how to write dual read channel ROM this way...

ROM IROM
(
	.Address( {1'b0,iInstructionReadAddress1[`ROM_ADDRESS_WIDTH-2:0]} ),
	`ifdef DEBUG
	.iDebug_CoreID(iDebug_CoreID),
	`endif
	.I( wRomDelay1 )
);

ROM IROM2
(
	.Address( {1'b0,iInstructionReadAddress2[`ROM_ADDRESS_WIDTH-2:0]} ),
	`ifdef DEBUG
	.iDebug_CoreID(iDebug_CoreID),
	`endif
	.I( wRomDelay2 )
);
//--------------------------------------------------------
ControlRegister CR
(
	.Clock( Clock ),
	.Reset( Reset ),
	.iControlRegister( iControlRegister ),
	.oControlRegister( oControlRegister )
);


endmodule
//-------------------------------------------------------------------