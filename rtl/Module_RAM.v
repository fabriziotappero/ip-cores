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
//--------------------------------------------------------
//Dual port RAM.


module RAM_DUAL_READ_PORT # ( parameter DATA_WIDTH=`DATA_ROW_WIDTH, parameter ADDR_WIDTH=`DATA_ADDRESS_WIDTH, parameter MEM_SIZE=128 )
(
	input wire						Clock,
	input wire						iWriteEnable,
	input wire[ADDR_WIDTH-1:0]	iReadAddress0,
	input wire[ADDR_WIDTH-1:0]	iReadAddress1,
	input wire[ADDR_WIDTH-1:0]	iWriteAddress,
	input wire[DATA_WIDTH-1:0]		 	iDataIn,
	output reg [DATA_WIDTH-1:0] 		oDataOut0,
	output reg [DATA_WIDTH-1:0] 		oDataOut1
);

reg [DATA_WIDTH-1:0] Ram [MEM_SIZE:0];		

always @(posedge Clock) 
begin 
	
		if (iWriteEnable) 
			Ram[iWriteAddress] <= iDataIn; 
			
	
			oDataOut0 <= Ram[iReadAddress0]; 
			oDataOut1 <= Ram[iReadAddress1]; 
		
end 
endmodule
//--------------------------------------------------------

module RAM_SINGLE_READ_PORT # ( parameter DATA_WIDTH=`DATA_ROW_WIDTH, parameter ADDR_WIDTH=`DATA_ADDRESS_WIDTH, parameter MEM_SIZE=128 )
(
	input wire						Clock,
	input wire						iWriteEnable,
	input wire[ADDR_WIDTH-1:0]	iReadAddress0,
	input wire[ADDR_WIDTH-1:0]	iWriteAddress,
	input wire[DATA_WIDTH-1:0]		 	iDataIn,
	output reg [DATA_WIDTH-1:0] 		oDataOut0
	
);

reg [DATA_WIDTH-1:0] Ram [MEM_SIZE:0];		

always @(posedge Clock) 
begin 
	
		if (iWriteEnable) 
			Ram[iWriteAddress] <= iDataIn; 
			
	
			oDataOut0 <= Ram[iReadAddress0]; 
			
		
end 
endmodule


