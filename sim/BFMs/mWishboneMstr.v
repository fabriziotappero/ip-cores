/*
This file belongs to Subtleware Corporation Pte Ltd 2011

File		:
Description	:
	Wishbone Master Functional Model
	pMode : Single or Pipelined
Remarks		:
TODO		: 
Revision	:
	Date	Author	Description

*/
`timescale 1ns/1ns
module mWishboneMstr #(parameter pAddrWidth=32,pDataWidth=32,pMode="Single") (
	output	reg o_WbCyc,
	output	reg o_WbStb,
	output	reg o_WbWEn,
	output	reg [pAddrWidth-1:00] ov_WbAddr,
	output	reg [pDataWidth-1:00]	ov_WbWrData,
	input	[pDataWidth-1:00] iv_WbRdData,
	input	i_Ack,
	input	i_Stall,
	input	i_Rty,
	input	i_Clk
);
	initial 
		begin
			o_WbCyc <= 1'b0;
			o_WbStb <= 1'b0;
			o_WbWEn <= 1'b0;
			ov_WbAddr <= 0;
			ov_WbWrData <= 0;
		end

	task tsk_Write;
		input [31:00] i32_Addr;
		input [31:00] i32_Data;
		
		begin
			@(posedge i_Clk);
			o_WbCyc <= 1'b1;
			o_WbStb <= 1'b1;
			o_WbWEn <= 1'b1;
			ov_WbAddr 	<= i32_Addr[pAddrWidth-1:00];
			ov_WbWrData <= i32_Data[pDataWidth-1:00];
			#1;
			@(posedge i_Clk);
			while(i_Ack==1'b0) @(posedge i_Clk);
			o_WbCyc <= 1'b0;
			o_WbStb <= 1'b0;
			o_WbWEn <= 1'b0;	
			@(posedge i_Clk);			
			@(posedge i_Clk);
		end
	endtask
	
	task tsk_Read;
		input [31:00] i32_Addr;
		output [31:00] o32_Data;
		
		begin
			@(posedge i_Clk);
			o_WbCyc <= 1'b1;
			o_WbStb <= 1'b1;
			o_WbWEn <= 1'b0;
			ov_WbAddr <= i32_Addr[pAddrWidth-1:00];			
			#1;
			@(posedge i_Clk);
			while(i_Ack==1'b0) @(posedge i_Clk);			
			o32_Data = iv_WbRdData;
			o_WbCyc <= 1'b0;
			o_WbStb <= 1'b0;
			o_WbWEn <= 1'b0;		
		end
	endtask
	



endmodule
