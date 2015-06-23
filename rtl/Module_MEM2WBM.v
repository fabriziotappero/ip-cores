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
This unit is used when the External Address that comes into IO is not a immediate value,
ie. it is a value that we need to read from one of our internal memory locations.
Since each internal memory locations contains 3 * 32bits slots, ie X,Y and Z parts of the
memory location, then we make three requests for external data, one for every X Y and Z
part of our internal registry.So, summarising, each internal memory location, stores 3 
external memory addresses to request to WBM. Once the 3 data has been read from outside world, 
they will get stored back into 3 consecutive inernal memory addreses starting from
iDataInitialStorageAddress
*/
//---------------------------------------------------------------------
module MEM2WBMUnitB
(
input wire                          Clock,
input wire                          Reset,
input wire									iEnable,
//output reg                          oSetAddress,
input wire[`DATA_ADDRESS_WIDTH-1:0]  iMEMDataPointer,
input wire[`DATA_ADDRESS_WIDTH-1:0]  iMEMDataPointer2,
output wire [`WIDTH-1:0]            oReadDataElement,
output wire [`WIDTH-1:0]            oReadDataElement2,
output wire[`DATA_ADDRESS_WIDTH-1:0] oDataReadAddress,    //This tells MEM unit from wich address we want to read
output wire[`DATA_ADDRESS_WIDTH-1:0] oDataReadAddress2,    //This tells MEM unit from wich address we want to read
input wire [`DATA_ROW_WIDTH-1:0]		iReadDataBus,		  //This comes from the MEM unit
input wire [`DATA_ROW_WIDTH-1:0]		iReadDataBus2,		  //This comes from the MEM unit
output wire									oDataWriteEnable,
output wire									oDataWriteEnable2,
output wire                          oDataAvailable,
input wire                          iRequestNextElement,
input wire[`DATA_ADDRESS_WIDTH-1:0]  iDataInitialStorageAddress, //Initial address to store data ////########
output wire[`DATA_ADDRESS_WIDTH-1:0] oDataWriteAddress,  //Were to store the values comming from WBM ////########
output wire                          oDone
);
assign oDataWriteEnable2 = 0;
assign oDataWriteEnable = 0; //We only read.
wire [3:0] wXYZSelector;
wire[`WIDTH-1:0] wValueFromBus,wLatchedValue;
assign oDataReadAddress = iMEMDataPointer;
assign oDataReadAddress2 = iMEMDataPointer2;
assign oDone = wXYZSelector[3];

wire wLacthNow;

wire iRequestNextElement_Delay;
FFD_POSEDGE_SYNCRONOUS_RESET # (1) FFD32_x 
(
	.Clock( 	Clock ),
	.Reset( 	Reset ),
	.Enable( 1'b1 ),
	.D( iRequestNextElement ),
	.Q( iRequestNextElement_Delay )
	
);

assign oDataAvailable = iEnable & ~iRequestNextElement_Delay & wLacthNow;// & ~oDone;

FFD_POSEDGE_SYNCRONOUS_RESET # (1) FFD32_EnableDelay 
(
	.Clock( 	Clock ),
	.Reset( 	Reset ),
	.Enable( 1'b1 ),
	.D( iEnable ),
	.Q( wLacthNow )
	
);

assign oDataWriteAddress = iDataInitialStorageAddress;


SHIFTLEFT_POSEDGE #(4) SHL
( 
  .Clock(iRequestNextElement | ~iEnable),
  .Enable(1'b1),
  .Reset(~iEnable | Reset ), 
  .Initial(4'b1), 
  .O(wXYZSelector)
  
);

MUXFULLPARALELL_3SEL_WALKINGONE MUXA
 (
 .Sel( wXYZSelector[2:0] ), 
 .I2( iReadDataBus[63:32]),
 .I1( iReadDataBus[95:64]),
 .I3( iReadDataBus[31:0] ),
 .O1( oReadDataElement )
 
 );



MUXFULLPARALELL_3SEL_WALKINGONE MUXA2
 (
 .Sel( wXYZSelector[2:0] ), 
 .I2( iReadDataBus2[63:32]),
 .I1( iReadDataBus2[95:64]),
 .I3( iReadDataBus2[31:0] ),
 .O1( oReadDataElement2 )
 );

endmodule
//---------------------------------------------------------------------