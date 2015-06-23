`timescale 1ns / 1ps
`include "aDefinitions.v"

module SWAP_MEM # ( parameter DATA_WIDTH=`DATA_ROW_WIDTH, parameter ADDR_WIDTH=`DATA_ADDRESS_WIDTH, parameter MEM_SIZE=128 )
(
	input wire								Clock,
	input wire								iSelect,
	input wire								iWriteEnableA,
	input wire[ADDR_WIDTH-1:0]			iReadAddressA0,
	input wire[ADDR_WIDTH-1:0]			iReadAddressA1,
	input wire[ADDR_WIDTH-1:0]			iWriteAddressA,
	input wire[DATA_WIDTH-1:0]		 	iDataInA,
	output wire [DATA_WIDTH-1:0] 		oDataOutA0,
	output wire [DATA_WIDTH-1:0] 		oDataOutA1,
	
	
	input wire								iWriteEnableB,
	input wire[ADDR_WIDTH-1:0]			iReadAddressB0,
	input wire[ADDR_WIDTH-1:0]			iReadAddressB1,
	input wire[ADDR_WIDTH-1:0]			iWriteAddressB,
	input wire[DATA_WIDTH-1:0]		 	iDataInB,
	output wire [DATA_WIDTH-1:0] 		oDataOutB0,
	output wire [DATA_WIDTH-1:0] 		oDataOutB1
);


wire								wWriteEnableA;
wire[ADDR_WIDTH-1:0]			wReadAddressA0;
wire[ADDR_WIDTH-1:0]			wReadAddressA1;
wire[ADDR_WIDTH-1:0]			wWriteAddressA;
wire[DATA_WIDTH-1:0]		 	wDataInA;
wire [DATA_WIDTH-1:0] 		wDataOutA0;
wire [DATA_WIDTH-1:0] 		wDataOutA1;

wire								wWriteEnableB;
wire[ADDR_WIDTH-1:0]			wReadAddressB0;
wire[ADDR_WIDTH-1:0]			wReadAddressB1;
wire[ADDR_WIDTH-1:0]			wWriteAddressB;
wire[DATA_WIDTH-1:0]		 	wDataInB;
wire [DATA_WIDTH-1:0] 		wDataOutB0;
wire [DATA_WIDTH-1:0] 		wDataOutB1;


assign wWriteEnableA = ( iSelect ) ? iWriteEnableA : iWriteEnableB;
assign wWriteEnableB = ( ~iSelect ) ? iWriteEnableA : iWriteEnableB;

assign wReadAddressA0 = ( iSelect ) ? iReadAddressA0 : iReadAddressB0;
assign wReadAddressB0 = ( ~iSelect ) ? iReadAddressA0 : iReadAddressB0;

assign wReadAddressA1 = ( iSelect ) ? iReadAddressA1 : iReadAddressB1;
assign wReadAddressB1 = ( ~iSelect ) ? iReadAddressA1 : iReadAddressB1;

assign wWriteAddressA = ( iSelect ) ? iWriteAddressA : iWriteAddressB;
assign wWriteAddressB = ( ~iSelect ) ? iWriteAddressA : iWriteAddressB;

assign wDataInA = ( iSelect ) ? iDataInA : iDataInB;
assign wDataInB = ( ~iSelect ) ? iDataInA : iDataInB;

assign oDataOutA0 = ( iSelect ) ? wDataOutA0 : wDataOutB0;
assign oDataOutB0 = ( ~iSelect ) ? wDataOutA0 : wDataOutB0;

assign oDataOutA1 = ( iSelect ) ? wDataOutA1 : wDataOutB1;
assign oDataOutB1 = ( ~iSelect ) ? wDataOutA1 : wDataOutB1;

RAM_DUAL_READ_PORT  # (DATA_WIDTH,ADDR_WIDTH,MEM_SIZE) MEM_A
(
	.Clock( Clock ),
	.iWriteEnable( wWriteEnableA ),
	.iReadAddress0( wReadAddressA0  ),
	.iReadAddress1( wReadAddressA1 ),
	.iWriteAddress( wWriteAddressA ),
	.iDataIn( wDataInA ),
	.oDataOut0( wDataOutA0 ),
	.oDataOut1( wDataOutA1 )
);


RAM_DUAL_READ_PORT  # (DATA_WIDTH,ADDR_WIDTH,MEM_SIZE) MEM_B
(
	.Clock( Clock ),
	.iWriteEnable( wWriteEnableB ),
	.iReadAddress0( wReadAddressB0  ),
	.iReadAddress1( wReadAddressB1 ),
	.iWriteAddress( wWriteAddressB ),
	.iDataIn( wDataInB ),
	.oDataOut0( wDataOutB0 ),
	.oDataOut1( wDataOutB1 )
);

endmodule
