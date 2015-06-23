/*
Copyright � 2012 JeffLieu-lieumychuong@gmail.com

	This file is part of SGMII-IP-Core.
    SGMII-IP-Core is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SGMII-IP-Core is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with SGMII-IP-Core.  If not, see <http://www.gnu.org/licenses/>.

File		:
Description	:	
Remarks		:	
Revision	:
	Date	Author		Description
02/09/12	Jefflieu
*/

`include "SGMIIDefs.v"
module mSyncCtrl (
	input	i_Clk,
	input 	i_Cke,
	input 	i_ARst_L,
	input	i_CtrlLoopBack,

	input	[07:00]	i8_RxCodeGroupIn,
	input	i_RxCodeInvalid,
	input	i_RxCodeCtrl,
	input	i_SignalDetect,
	output reg	[07:00]	o8_RxCodeGroupOut,
	output	o_RxEven,
	output	reg o_RxCodeInvalid,
	output	reg o_RxCodeCtrl,
	output reg	o_SyncStatus,
	output	o_BitSlip,
	output	o_IsComma,
	output	o_OrderedSetValid,
	output	o_IsI1Set,
	output	o_IsI2Set,
	output	o_IsC1Set,
	output	o_IsC2Set,
	output	reg o_IsTSet,
	output	reg o_IsVSet,
	output	reg o_IsSSet,
	output	reg o_IsRSet);

localparam stLOSS_OF_SYNC		=	13'h0001;
localparam stCOMMA_DTEC_1		=	13'h0002;
localparam stACQ_SYNC_1			=	13'h0004;
localparam stCOMMA_DTEC_2		=	13'h0008;
localparam stACQ_SYNC_2			=	13'h0010;
localparam stCOMMA_DTEC_3		=	13'h0020;
localparam stSYNC_ACQUIRED_1	=	13'h0040;
localparam stSYNC_ACQUIRED_2	=	13'h0080;
localparam stSYNC_ACQUIRED_2A	=	13'h0100;
localparam stSYNC_ACQUIRED_3	=	13'h0200;
localparam stSYNC_ACQUIRED_3A	=	13'h0400;
localparam stSYNC_ACQUIRED_4	=	13'h0800;
localparam stSYNC_ACQUIRED_4A	=	13'h1000;

reg 	[12:00]	r13_State;
reg		r_RxEven;
wire	w_SignalDetectChange;
reg		r_LastSignalDetect;
reg 	[02:00]	r3_GoodCgs;
wire	w_CgBad;
wire	w_IsComma;
wire	w_IsData;
reg		r_IsComma;
wire	w_IsC1Set;
wire	w_IsC2Set;
wire	w_IsI1Set;
wire	w_IsI2Set;
wire	w_IsRSet;
wire	w_IsSSet;
wire	w_IsTSet;
wire	w_IsVSet;
reg		r_IsRSTV;
wire [3:0] w4_ID1;
reg	 [3:0] r4_ID2;

	//MainStatemachine
	assign w_IsComma = (~i_RxCodeInvalid) && (i_RxCodeCtrl) && (i8_RxCodeGroupIn==8'hBC||i8_RxCodeGroupIn==8'h3C||i8_RxCodeGroupIn==8'hFC);
	assign w_IsData	 = (~i_RxCodeInvalid) && (~i_RxCodeCtrl);
	assign w_CgBad 	= i_RxCodeInvalid|(w_IsComma & r_RxEven);
	assign w_SignalDetectChange = r_LastSignalDetect^i_SignalDetect;
	always@(posedge i_Clk or negedge i_ARst_L)
	begin: MainStatemachine
		if(i_ARst_L==1'b0) begin
			r13_State <= stLOSS_OF_SYNC;
		end
		else if(i_Cke) begin
			r_LastSignalDetect <= i_SignalDetect;
			if(w_SignalDetectChange & (~i_RxCodeInvalid) & ~i_CtrlLoopBack)
				r13_State <= stLOSS_OF_SYNC;
			else
				case(r13_State)				
				stLOSS_OF_SYNC		:	if(w_IsComma && (i_SignalDetect||i_CtrlLoopBack)) r13_State <= stCOMMA_DTEC_1;
				stCOMMA_DTEC_1		:	if(w_IsData) r13_State <= stACQ_SYNC_1; else r13_State <= stLOSS_OF_SYNC;
				stACQ_SYNC_1		:	if(w_CgBad) r13_State <= stLOSS_OF_SYNC; else		
											if(r_RxEven==1'b0 && w_IsComma) r13_State <= stCOMMA_DTEC_2;
				stCOMMA_DTEC_2		:	if(w_IsData) r13_State <= stACQ_SYNC_2; else r13_State <= stLOSS_OF_SYNC;
				stACQ_SYNC_2		:	if(w_CgBad) r13_State <= stLOSS_OF_SYNC; else		
											if(r_RxEven==1'b0 && w_IsComma) r13_State <= stCOMMA_DTEC_3;
				stCOMMA_DTEC_3		:	if(w_IsData) r13_State <= stSYNC_ACQUIRED_1; else r13_State <= stLOSS_OF_SYNC;
				stSYNC_ACQUIRED_1	: 	if(w_CgBad) r13_State <= stSYNC_ACQUIRED_2; 
				stSYNC_ACQUIRED_2	: 	if(w_CgBad) r13_State <= stSYNC_ACQUIRED_3; else r13_State <= stSYNC_ACQUIRED_2A;
				stSYNC_ACQUIRED_2A	:	if(w_CgBad) r13_State <= stSYNC_ACQUIRED_3; else		
											if(r3_GoodCgs==3) r13_State <= stSYNC_ACQUIRED_1;
				stSYNC_ACQUIRED_3	:	if(w_CgBad) r13_State <= stSYNC_ACQUIRED_4; else r13_State <= stSYNC_ACQUIRED_3A;
				stSYNC_ACQUIRED_3A	:	if(w_CgBad) r13_State <= stSYNC_ACQUIRED_4; else		
											if(r3_GoodCgs==3) r13_State <= stSYNC_ACQUIRED_2;
				stSYNC_ACQUIRED_4	:	if(w_CgBad) r13_State <= stLOSS_OF_SYNC; else r13_State <= stSYNC_ACQUIRED_4A;
				stSYNC_ACQUIRED_4A	:	if(w_CgBad) r13_State <= stLOSS_OF_SYNC; else		
											if(r3_GoodCgs==3) r13_State <= stSYNC_ACQUIRED_3;
				endcase
		end
	end

	always@(posedge i_Clk or negedge i_ARst_L)
	begin: SignalControl
		if(i_ARst_L==1'b0) begin
			r_RxEven <= 1'b0;
		end
		else if(i_Cke) begin
			if((r13_State==stLOSS_OF_SYNC&&(w_IsComma && (i_SignalDetect||i_CtrlLoopBack)))||
					((r13_State==stACQ_SYNC_1||r13_State==stACQ_SYNC_2)&&(r_RxEven==1'b0 && w_IsComma)))
					r_RxEven<=1'b1;
			else
				r_RxEven <= ~r_RxEven;
			if(r13_State==stSYNC_ACQUIRED_1) 
				o_SyncStatus <= 1'b1;
			else if(r13_State==stLOSS_OF_SYNC)
				o_SyncStatus <= 1'b0;
			
			if(r13_State==stSYNC_ACQUIRED_2A||r13_State==stSYNC_ACQUIRED_3A||r13_State==stSYNC_ACQUIRED_4A)
				r3_GoodCgs <= r3_GoodCgs+3'h1; 
			else if(r13_State==stSYNC_ACQUIRED_2||r13_State==stSYNC_ACQUIRED_3||r13_State==stSYNC_ACQUIRED_4)
				r3_GoodCgs <= 3'h0;
			
			o8_RxCodeGroupOut <= i8_RxCodeGroupIn;
			o_RxCodeInvalid <= i_RxCodeInvalid;
			o_RxCodeCtrl 	<= i_RxCodeCtrl;
		end
	end
	
	assign o_RxEven = r_RxEven;

	//ordered set detection
	assign o_OrderedSetValid = r_IsComma | r_IsRSTV;
	assign w_IsC1Set = r_IsComma && w_IsData && (i8_RxCodeGroupIn==`D21_5);
	assign w_IsC2Set = r_IsComma && w_IsData && (i8_RxCodeGroupIn==`D2_2);
	assign w_IsI1Set = r_IsComma && w_IsData && (i8_RxCodeGroupIn==`D5_6);
	assign w_IsI2Set = r_IsComma && w_IsData && (i8_RxCodeGroupIn==`D16_2);
	assign w_IsRSet	 = i_RxCodeCtrl && (~i_RxCodeInvalid) && (i8_RxCodeGroupIn==`K23_7);
	assign w_IsSSet	 = i_RxCodeCtrl && (~i_RxCodeInvalid) && (i8_RxCodeGroupIn==`K27_7);
	assign w_IsTSet	 = i_RxCodeCtrl && (~i_RxCodeInvalid) && (i8_RxCodeGroupIn==`K29_7);
	assign w_IsVSet	 = i_RxCodeCtrl && (~i_RxCodeInvalid) && (i8_RxCodeGroupIn==`K30_7);
	
	assign o_IsC1Set = w_IsC1Set;
	assign o_IsC2Set = w_IsC2Set;
	assign o_IsI1Set = w_IsI1Set;
	assign o_IsI2Set = w_IsI2Set;	
	assign o_IsComma = r_IsComma;
	
	always@(posedge i_Clk or negedge i_ARst_L )
	if(!i_ARst_L) begin
		r_IsComma <= 1'b0;	
		r_IsRSTV <= 1'b0;
	end else begin	
		r_IsComma <= w_IsComma;	
		r_IsRSTV <= w_IsRSet | w_IsSSet | w_IsTSet | w_IsVSet;
		o_IsRSet <= w_IsRSet;
		o_IsSSet <= w_IsSSet;
		o_IsTSet <= w_IsTSet;
		o_IsVSet <= w_IsVSet;			
	end
	
	//synthesis translate_off
	reg [239:0] r240_SyncStateName;
	always@(*)
	case(r13_State)
	stLOSS_OF_SYNC		: r240_SyncStateName<="stLOSS_OF_SYNC		";
	stCOMMA_DTEC_1		: r240_SyncStateName<="stCOMMA_DTEC_1		";
	stACQ_SYNC_1		: r240_SyncStateName<="stACQ_SYNC_1			";	
	stCOMMA_DTEC_2		: r240_SyncStateName<="stCOMMA_DTEC_2		";
	stACQ_SYNC_2		: r240_SyncStateName<="stACQ_SYNC_2			";	
	stCOMMA_DTEC_3		: r240_SyncStateName<="stCOMMA_DTEC_3		";
	stSYNC_ACQUIRED_1	: r240_SyncStateName<="stSYNC_ACQUIRED_1	";
	stSYNC_ACQUIRED_2	: r240_SyncStateName<="stSYNC_ACQUIRED_2	";
	stSYNC_ACQUIRED_2A	: r240_SyncStateName<="stSYNC_ACQUIRED_2A	";
	stSYNC_ACQUIRED_3	: r240_SyncStateName<="stSYNC_ACQUIRED_3	";
	stSYNC_ACQUIRED_3A	: r240_SyncStateName<="stSYNC_ACQUIRED_3A	";
	stSYNC_ACQUIRED_4	: r240_SyncStateName<="stSYNC_ACQUIRED_4	";
	stSYNC_ACQUIRED_4A	: r240_SyncStateName<="stSYNC_ACQUIRED_4A	";
	endcase	
	//synthesis translate_on
	reg [3:0] r7_SlipTmr =0;		
	always@(posedge i_Clk or negedge i_ARst_L)
	if(~i_ARst_L)
		r7_SlipTmr  <= 7'h0;
	else begin 
		
		if(r13_State==stLOSS_OF_SYNC) begin 
			if(w_IsComma) r7_SlipTmr <= 0;			
			else r7_SlipTmr <= r7_SlipTmr+7'h1;							
			end
		else r7_SlipTmr <= 0;
		end
	assign o_BitSlip = &r7_SlipTmr[3:0]; 	
		
endmodule
