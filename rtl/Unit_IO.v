`timescale 1ns / 1ps
`include "aDefinitions.v"
`define ADR_IMM 1
`define ADR_POINTER 0
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
//--------------------------------------------------------------------------
module IO_Unit
(
 input wire                            Clock,
 input wire                            Reset,
 input wire                            iEnable,
 input wire [`DATA_ADDRESS_WIDTH-1:0]  iDat_O_Pointer,     //Pointer to what we want to send via DAT_O
 input wire [`WIDTH-1:0]               iAdr_O_Imm,         //Value to assign to ADR_O
 input wire [`DATA_ADDRESS_WIDTH-1:0]  iAdr_O_Pointer,     //Pointer to value to assing to ADR_O
 input wire                            iAdr_O_Type,        //Should we use iAdr_O_Imm or iAdr_O_Pointer
 input wire                            iAdr_O_Set,		     //Should we set 
 input wire                            iBusCyc_Type,       //Bus cycle type: simple read/write, etc.
 input wire                            iStore,             //Should we store read data into MEM
 input wire [`DATA_ROW_WIDTH-1:0]      iReadDataBus,       //MEM Data read bus 1
 input wire [`DATA_ROW_WIDTH-1:0]      iReadDataBus2,      //MEM Data read bus 2
 input wire[`DATA_ADDRESS_WIDTH-1:0]   iAdr_DataWriteBack, //Where in MEM we want to store DAT_I
 input wire                            iWriteBack_Set,     //We want to set the Write back Address?
 
 
 output wire[`DATA_ADDRESS_WIDTH-1:0]  oDataReadAddress,
 output wire[`DATA_ADDRESS_WIDTH-1:0]  oDataReadAddress2,
 output wire[`DATA_ADDRESS_WIDTH-1:0]  oDataWriteAddress,
 output wire                           oDataWriteEnable,
 output wire [`DATA_ROW_WIDTH-1:0]     oDataBus,
 output wire [`INSTRUCTION_WIDTH-1:0]  oInstructionBus,
 output wire                           oInstructionWriteEnable,
 output wire [`ROM_ADDRESS_WIDTH-1:0]  oInstructionWriteAddress,
 inout wire [`WIDTH-1:0]               oData,
 output wire                           oBusy,
 output wire                           oDone,
 
 
 input wire [`DATA_ROW_WIDTH-1:0]  iOMEM_WriteAddress,
 input wire [`DATA_ROW_WIDTH-1:0]  iOMEM_WriteData,
 input wire                  iOMEM_WriteEnable,
 output wire [`WB_WIDTH-1:0] OMEM_DAT_O,
 output wire [`WB_WIDTH-1:0] OMEM_ADR_O,
 output wire 					  OMEM_WE_O,
 
 //Theia specific interfaces
 input wire MST_I,
 //Wish Bone Interfaces
output wire [31:0]   DAT_O, 
input wire [31:0]    DAT_I,
input wire           ACK_I,
output wire          ACK_O,
output wire [31:0]   ADR_O,
input wire [31:0]   ADR_I,
output wire          WE_O,
input wire           WE_I,
output wire          STB_O,
input wire           STB_I,
output wire          CYC_O,
input wire           CYC_I,
input wire  [1:0]    TGA_I,    
output wire	[1:0]    TGC_O,
input wire           GNT_I,


output wire [`DATA_ROW_WIDTH-1:0] oTMEMReadData,
input wire 								 iTMEMDataRequest,
input wire 	[`DATA_ROW_WIDTH-1:0] iTMEMReadAddress,	
output wire 							 oTMEMDataAvailable, 

input wire                  TMEM_ACK_I,
input wire [`WB_WIDTH-1:0]  TMEM_DAT_I , 
output wire [`WB_WIDTH-1:0] TMEM_ADR_O ,
output wire                 TMEM_WE_O,
output wire                 TMEM_STB_O,
output wire                 TMEM_CYC_O,
input wire                  TMEM_GNT_I
);


wire [`WIDTH-1:0]          wMEMToWBM2__ReadDataElement; 
wire [`WIDTH-1:0]          wMEMToWBM2__ReadDataElement2; 
wire                       wMEMToWBM_2__Enable;
wire                       wWBMToMEM2__Done;
wire                       wWBM_2_WBMToMEM_DataAvailable;
wire [`WIDTH-1:0]          wWBM_2_WBMToMEM_Data;
wire [`WIDTH-1:0]          wWBS_2__WBMToMEM_Frame;
wire                       wWBMToMEM_2_WBM_Enable;
wire [`WIDTH-1:0]          wWBMToMEM_2_WBM_Address;
wire                       wWBMToMEM2__oDataWriteEnable;
wire                       wAddrerssSelector2_oDataWriteEnable;
wire [`DATA_ROW_WIDTH-1:0] wWBMToMEM2__oDataBus;
wire [`DATA_ROW_WIDTH-1:0] wWBSToMEM2__oDataBus;
wire                       wAddressSelector_2__SetAddress;
wire [`WIDTH-1:0]          wMEMToWBM_2__Address;
wire                       wMEMToWBM_2__Done;
wire                       w2WBMToMEM__Enable;
wire                       w2WBMToMEM__SetAddress;
wire                       wWBS_2__WBSToMEM_FrameAvailable;
wire[`WIDTH-1:0]           wWBS_2__WBMToMEM_Address;
wire                       wWBSToMEM2__oDataWriteEnable;
wire[`DATA_ADDRESS_WIDTH-1:0] wWBSToMEM2__oDataWriteAddress;
wire[`DATA_ADDRESS_WIDTH-1:0] wWBMToMEM2__oDataWriteAddress;



 //***********new*****************/


Module_OMemInterface OMI
(
	.Clock( Clock ),
	.Reset( Reset ),
	.iWriteEnable( iOMEM_WriteEnable  ),
	.iData(        iOMEM_WriteData    ),
	.iAddress(     iOMEM_WriteAddress ),
	.ADR_O(        OMEM_ADR_O         ),
	.DAT_O(        OMEM_DAT_O         ),
	.WE_O(         OMEM_WE_O          )
	
);

Module_TMemInterface TMI
(
	.Clock( Clock ),
	.Reset( Reset ),
	.iEnable(  iTMEMDataRequest   ),
	.iAddress( iTMEMReadAddress   ),	
	.oData(    oTMEMReadData      ),
	.oDone(    oTMEMDataAvailable ),

	.ACK_I( TMEM_ACK_I ),
	.GNT_I( TMEM_GNT_I ), 
	.DAT_I( TMEM_DAT_I ),
	.ADR_O( TMEM_ADR_O ),
	.WE_O(  TMEM_WE_O  ),
	.STB_O( TMEM_STB_O ),
	.CYC_O( TMEM_CYC_O )	
	

);
//***********new*****************/

assign oBusy = CYC_O;
wire wReadOperation;
assign wReadOperation = (iBusCyc_Type == `WB_SIMPLE_WRITE_CYCLE) ? 0 : 1;

 
assign wMEMToWBM_2__Address    = ( iAdr_O_Type == `ADR_IMM ) ? iAdr_O_Imm  : wMEMToWBM2__ReadDataElement;
assign w2WBMToMEM__Enable    = ( iAdr_O_Type == `ADR_IMM ) ? iEnable       : wMEMToWBM_2__Enable;
//assign oDone                  = ( (iAdr_O_Type == `ADR_IMM) && !(iBusCyc_Type == `WB_SIMPLE_WRITE_CYCLE) ) 
//? wWBMToMEM2__Done : wMEMToWBM_2__Done;

//TODO: WHEN ADR_POINTER Then Done is not until we got the 3 values from X,Y,Z in iAdr_O_Pointer
assign oDone = (iBusCyc_Type == `WB_SIMPLE_WRITE_CYCLE || iAdr_O_Type == `ADR_POINTER ) ? wMEMToWBM_2__Done : wWBMToMEM2__Done;

assign oDataWriteEnable  = (MST_I == 1'b1) ? wWBSToMEM2__oDataWriteEnable : (wWBMToMEM2__oDataWriteEnable);// ^ wAddrerssSelector2_oDataWriteEnable);
assign oDataWriteAddress = (MST_I == 1'b1) ? wWBSToMEM2__oDataWriteAddress : wWBMToMEM2__oDataWriteAddress;
assign oDataBus          = (MST_I == 1'b1) ? wWBSToMEM2__oDataBus : wWBMToMEM2__oDataBus;



 
 
 wire [`DATA_ADDRESS_WIDTH-1:0] wMEMToWBM2_WBMToMEM_RAMWriteAddr;
 wire [`DATA_ADDRESS_WIDTH-1:0] w2WBMToMEM_MEMWriteAddress;

assign w2WBMToMEM_MEMWriteAddress = ( iAdr_O_Type == `ADR_IMM) ? iAdr_DataWriteBack : wMEMToWBM2_WBMToMEM_RAMWriteAddr;

wire w2MEMToWBM_BusOperationComplete;
assign w2MEMToWBM_BusOperationComplete = (iBusCyc_Type == `WB_SIMPLE_WRITE_CYCLE) ? ACK_I  :  wWBMToMEM2__Done;


wire [`DATA_ADDRESS_WIDTH-1:0] w2MEMToWBM_DataPointer;
assign w2MEMToWBM_DataPointer = (iBusCyc_Type == `WB_SIMPLE_WRITE_CYCLE) ? iDat_O_Pointer : iAdr_O_Pointer;


//------------------------------------------------------------------------------
MEM2WBMUnitB MEMToWBM
(
.Clock(                        Clock                                           ),
.Reset(                        Reset                                           ),
.iEnable(                      iEnable & (~iAdr_O_Type | iBusCyc_Type)         ),
.iMEMDataPointer(           w2MEMToWBM_DataPointer                          ),
.iMEMDataPointer2(           iAdr_O_Pointer                          ),
.iReadDataBus(                 iReadDataBus							                ),   //3 Elements comming from DMEM
.iReadDataBus2(                iReadDataBus2                                   ),
.oReadDataElement(             wMEMToWBM2__ReadDataElement                     ),	//1 out of 3 elements we read
.oReadDataElement2(            wMEMToWBM2__ReadDataElement2                     ),	//1 out of 3 elements we read
.oDataReadAddress(              oDataReadAddress                                ),
.oDataReadAddress2(              oDataReadAddress2                             ),
.oDataWriteEnable(              wAddrerssSelector2_oDataWriteEnable             ),   //Always zero
.oDataAvailable(              wMEMToWBM_2__Enable                             ),    //Data from MEM available
.iRequestNextElement(          w2MEMToWBM_BusOperationComplete                 ),
.iDataInitialStorageAddress(    iAdr_DataWriteBack                              ), ////########
.oDataWriteAddress(             wMEMToWBM2_WBMToMEM_RAMWriteAddr        ), ////########
.oDone(                        wMEMToWBM_2__Done                               )
);
//------------------------------------------------------------------------------





wire [`DATA_ADDRESS_WIDTH-1:0] wTemp1;
 assign wWBMToMEM2__oDataWriteAddress = (iAdr_O_Type == `ADR_IMM) ? iAdr_DataWriteBack : wTemp1;
 


wire [`WIDTH-1:0] wADR_O_InitialAddress;
assign wADR_O_InitialAddress = (iBusCyc_Type == `WB_SIMPLE_WRITE_CYCLE) ? wMEMToWBM2__ReadDataElement2 : wMEMToWBM_2__Address;
wire wIncrement_Address_O;
assign wIncrement_Address_O = iEnable & ACK_I;



wire                 wMEMToWBM2__Done;
wire                 wMEMToWBM2__Trigger;
wire[`WB_WIDTH-1:0]  wMEMToWBM_2_Data;
wire                 w2MEMToWBM__Trigger;
wire                 wWBM2_MEMToWBM_DataWriteDone;


wire w2WBM_iEnable;

assign w2WBM_iEnable = (iBusCyc_Type == `WB_SIMPLE_WRITE_CYCLE) ? wMEMToWBM_2__Enable : iEnable;

//------------------------------------------------------------------------------
wire wSTB_O;

//If the address is a pointer, we need 1 cycle to read the data back from MEM
//before we can the set the value into WBM
wire wAddress_Set_Delayed;
FFD_POSEDGE_SYNCRONOUS_RESET # (1) FFD32_SetDelay 
(
	.Clock( 	Clock ),
	.Reset( 	Reset ),
	.Enable( 1'b1 ),
	.D( iAdr_O_Set ),
	.Q( wAddress_Set_Delayed )
	
);

//If the Addr is IMM then just set it whenever iAdr_O_Set is set, but if we have a pointer, then use
//wAddress_Set_Delayed at the beginning and then wWBMToMEM2__Done
wire wWBM_iAddress_Set = (iAdr_O_Type == `ADR_POINTER) ? (wAddress_Set_Delayed | wWBMToMEM2__Done) : 	iAdr_O_Set;

assign STB_O = wSTB_O & ~oDone;

	WishBoneMasterUnit WBM
	(
		.CLK_I( 	Clock ),
		.RST_I( 	Reset ),
		.DAT_I( 	DAT_I ),
		.DAT_O(  DAT_O ),
		.ACK_I( 	ACK_I  ),
		.ADR_O( 	ADR_O ),
		.WE_O( 	WE_O ),
		.STB_O(	wSTB_O ),
		.CYC_O(	CYC_O	),
		.TGC_O(	TGC_O	),
		.GNT_I(  GNT_I ),
		
		.iEnable( 			w2WBM_iEnable       ),
		.iBusCyc_Type(    iBusCyc_Type                     ),
		.iAddress_Set(  wWBM_iAddress_Set  ),
		.iAddress( 	      wADR_O_InitialAddress            ),
		.oDataReady( 		wWBM_2_WBMToMEM_DataAvailable    ),
		.iData(           wMEMToWBM2__ReadDataElement      ),
		.oData( 				wWBM_2_WBMToMEM_Data 			   ) 
	);
	
//------------------------------------------------------------------------------
WishBoneSlaveUnit WBS
(

		.CLK_I( 	Clock  ),
		.RST_I( 	Reset  ),
		.STB_I(  STB_I  ),
	   .WE_I(   WE_I   ),
		.DAT_I(  DAT_I  ),
	   .ADR_I(  ADR_I  ),
		.TGA_I(  TGA_I  ),
		.ACK_O(  ACK_O  ),
		.CYC_I(  CYC_I  ),
		.MST_I(  MST_I ),
		
		.oDataBus(               wWBSToMEM2__oDataBus                    ),
		.oInstructionBus(        oInstructionBus                         ),
		.oDataWriteAddress(      wWBSToMEM2__oDataWriteAddress           ), 
		.oDataWriteEnable(       wWBSToMEM2__oDataWriteEnable            ),
		.oInstructionWriteAddress(      oInstructionWriteAddress         ), 
		.oInstructionWriteEnable(       oInstructionWriteEnable          ) 


		
);
//------------------------------------------------------------------------------


endmodule
//--------------------------------------------------------------------------