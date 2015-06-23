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
Remarks		:	No Support for Next Page
Revision	:
	Date	Author		Description
02/09/12	Jefflieu
*/

`include "SGMIIDefs.v"

`timescale 1ns/100ps


`define c10ms		(10_000_000/`cSystemClkPeriod)
`define c1p6ms		(00_001_000/`cSystemClkPeriod)




module mANCtrl(
	input 	i_Clk,
	input 	i_ARst_L,
	input	i_Cke,
	input	i_RestartAN,
	input	i_SyncStatus,
	input	i_ANEnable,
	
	input	[20:00] i21_LinkTimer,
	output	[15:00] o16_LpAdvAbility,
	input	[16:01] i16_LcAdvAbility,
	
	input	[15:00] i16_RxConfigReg,
	input	i_RUDIConfig,
	input	i_RUDIIdle,
	input	i_RUDIInvalid,
	output	o_ANComplete,
	output	reg [02:00]	o3_Xmit,
	output	reg [15:00]	o16_TxConfigReg);
	
	
	localparam 	stAN_ENABLE 	= 8'h01,
				stAN_RESTART 	= 8'h02,
				stABILITY_DTECT	= 8'h04,
				stACK_DTECT		= 8'h08,
				stCMPLT_ACK		= 8'h10,
				stIDLE_DTECT	= 8'h20,
				stLINK_OK		= 8'h40,
				stAN_DIS_LINKOK	= 8'h80;
	

	
	reg	[20:00]	r21_LinkTimer;
	reg	[02:00]	r2_RxCfgRegMchCntr;
	wire	w_AbiMatch;
	reg		r_ConsistencyMatch;
	wire	w_AckMatch;
	reg [07:00] r8_State;
	reg r_ANEable;
	wire	w_LinkTimerDone;
	reg [16:01] r16_LpAdvAbility;	//Link partner Advertised Ability, updated every time RUDIConfig is valid
	reg	r_NxtPage;
	reg r_NxtPageLoaded;
	reg r_ToggleTx;
	reg r_ToggleRx;
	reg [01:00] r2_AbilityMatchCnt;
	reg [01:00] r2_ConsistMatchCnt;
	reg [01:00] r2_AcknowlMatchCnt;
	reg [15:00] r16_AbilityReg;		//Captured of Partner Ability before going to Acknowledge Detect
	reg [01:00] r2_IdleMatchCnt;
	wire w_IdleMatch;
	
	assign w_LinkTimerDone = (r21_LinkTimer==i21_LinkTimer)?1'b1:1'b0;
	assign w_AbiMatch = (r2_AbilityMatchCnt==2'b11)?1'b1:1'b0;	
	assign w_AckMatch = (r2_AcknowlMatchCnt==2'b11)?1'b1:1'b0;
	assign w_IdleMatch = (r2_IdleMatchCnt==2'b11)?1'b1:1'b0;
	assign o16_LpAdvAbility = r16_LpAdvAbility;
	assign o_ANComplete = (r8_State==stLINK_OK)?1'b1:1'b0;
	always@(posedge i_Clk or negedge i_ARst_L)
	if(i_ARst_L==1'b0) begin
		r8_State <= stAN_ENABLE;
	end else begin
		r_ANEable <= i_ANEnable;
		if((~i_Cke) || i_RestartAN || (~i_SyncStatus) || i_RUDIInvalid || (r_ANEable^i_ANEnable))
			r8_State <= stAN_ENABLE;
		else
			case(r8_State)
			stAN_ENABLE		:	if(i_ANEnable) r8_State <= stAN_RESTART; else r8_State <= stAN_DIS_LINKOK;
			stAN_RESTART	:	if(w_LinkTimerDone) r8_State <= stABILITY_DTECT;
			stABILITY_DTECT	:	if(w_AbiMatch && r16_LpAdvAbility!=16'h0000) r8_State <= stACK_DTECT;
			stACK_DTECT		:	if((w_AckMatch && (~r_ConsistencyMatch))||(w_AbiMatch && i16_RxConfigReg==16'h0000 && i_RUDIConfig))
									r8_State <= stAN_ENABLE;
								else if(w_AckMatch && r_ConsistencyMatch)
									r8_State <= stCMPLT_ACK;
			stCMPLT_ACK		:	if(w_AbiMatch && r16_LpAdvAbility==16'h0000) r8_State <= stAN_ENABLE; 
								else if(w_LinkTimerDone && (~w_AbiMatch||(r16_LpAdvAbility!=16'h0000)))
												r8_State <= stIDLE_DTECT;								
			stIDLE_DTECT	:	if(w_IdleMatch && w_LinkTimerDone) r8_State <= stLINK_OK; else		
									if(w_AbiMatch && r16_LpAdvAbility==16'h0000) r8_State <= stAN_ENABLE;
						
			stLINK_OK		:	if(w_AbiMatch) r8_State <= stAN_ENABLE;
			stAN_DIS_LINKOK	:	r8_State <= stAN_DIS_LINKOK;	
			endcase			
	end

	always@(posedge i_Clk or negedge i_ARst_L)
	if(!i_ARst_L) begin
		r16_LpAdvAbility	<= 16'h0000;
		o3_Xmit				<= `cXmitIDLE;
		r21_LinkTimer 		<= 21'h0;
		o16_TxConfigReg 	<= 16'h0;	
		r2_IdleMatchCnt		<= 2'b00;		
		r16_AbilityReg 		<= 16'h0;
	end else begin
		//Xmit 
		case(r8_State)
		stAN_ENABLE : if(i_ANEnable) o3_Xmit <= `cXmitCONFIG; else o3_Xmit <= `cXmitIDLE;
		stIDLE_DTECT: o3_Xmit <= `cXmitIDLE;
		stLINK_OK	: o3_Xmit <= `cXmitDATA;
		stAN_DIS_LINKOK: o3_Xmit <= `cXmitDATA;
		endcase
		
		case(r8_State)
		stAN_ENABLE: r21_LinkTimer <= 21'h0;
		stAN_RESTART: if(w_LinkTimerDone==1'b0) r21_LinkTimer <= r21_LinkTimer+21'h1;
		stACK_DTECT : r21_LinkTimer <= 21'h0;
		stCMPLT_ACK	: if(w_LinkTimerDone && (~w_AbiMatch||(r16_LpAdvAbility!=16'h0000))) r21_LinkTimer <= 21'h0; else		
						if(w_LinkTimerDone==1'b0) r21_LinkTimer <= r21_LinkTimer+21'h1;
		stIDLE_DTECT: if(w_LinkTimerDone==1'b0) r21_LinkTimer <= r21_LinkTimer+21'h1;
		stLINK_OK	: r21_LinkTimer <= 21'h0;
		endcase
		
							
		case(r8_State)
		stAN_ENABLE: if(i_ANEnable) o16_TxConfigReg <= 16'h0000;
		stAN_RESTART: if(w_LinkTimerDone) begin
						o16_TxConfigReg[15] <= i16_LcAdvAbility[16];
						o16_TxConfigReg[14] <= 1'b0;
						o16_TxConfigReg[13:0] <= i16_LcAdvAbility[14:1];						
						end
		stACK_DTECT : o16_TxConfigReg[14] <= 1'b1;
		endcase
		
		
		if(r8_State==stABILITY_DTECT) r_ToggleTx <= i16_LcAdvAbility[12];
		else if(r8_State==stCMPLT_ACK) r_ToggleTx <= ~r_ToggleTx;
		
		if(r8_State==stCMPLT_ACK) r_ToggleRx<=i16_RxConfigReg[11];
		
		//Sync Reset
		if(r8_State==stAN_RESTART)
		begin
			r2_AbilityMatchCnt 	<= 2'b00;
			r16_AbilityReg		<= 16'h0;
			r16_LpAdvAbility 	<= 16'h0;
			r2_AcknowlMatchCnt	<= 2'b00;
			r_ConsistencyMatch	<= 1'b0;
			r2_IdleMatchCnt		<= 2'b00;
		end else
		begin		
			//w_AbiMatch		
			if(i_RUDIIdle)
				r2_AbilityMatchCnt <= 2'b00;
			else if(i_RUDIConfig) begin
				if(i16_RxConfigReg[13:00] == r16_LpAdvAbility[14:01] && i16_RxConfigReg[15]==r16_LpAdvAbility[16]) 
					begin
					if(r2_AbilityMatchCnt!=2'b11) r2_AbilityMatchCnt<=r2_AbilityMatchCnt+1;				
					end
				else 
					r2_AbilityMatchCnt <= 2'b01;
			end
			
			if(r8_State==stABILITY_DTECT && w_AbiMatch && r16_LpAdvAbility!=16'h00) r16_AbilityReg <= r16_LpAdvAbility;
				
			//Ack Match
			if(i_RUDIIdle)
				r2_AcknowlMatchCnt <= 2'b00;
			else if(i_RUDIConfig) begin
				if(i16_RxConfigReg[15:00] == r16_LpAdvAbility[16:01] && (i16_RxConfigReg[14]==1'b1)) 
					begin
					if(r2_AcknowlMatchCnt!=2'b11) r2_AcknowlMatchCnt<=r2_AcknowlMatchCnt+1;
					//Consistency Match
					//When the flag acknowledge match is about to be set
					//If the bits are same as r16_LpAdvAbility , consistent
					//Else Not consistent;
					//Consistency match is set at the same time as Acknowledge match
					if(r2_AcknowlMatchCnt==2'b10 && (i16_RxConfigReg[13:00] == r16_AbilityReg[13:00] && i16_RxConfigReg[15]==r16_AbilityReg[15]))
						r_ConsistencyMatch <= 1'b1; else r_ConsistencyMatch<=1'b0;
					end
				else 
					r2_AcknowlMatchCnt <= 2'b01;
			end
					
			
			if(i_RUDIConfig)
				r16_LpAdvAbility <= i16_RxConfigReg;			
		
			if(i_RUDIIdle) r2_IdleMatchCnt <= r2_IdleMatchCnt+2'b01;
				else if(i_RUDIConfig|i_RUDIInvalid) r2_IdleMatchCnt<=2'b00;
		
		end
	end
	
	//synopsys synthesis_off
	reg [239:0] r240_ANStateName;
	always@(*)
	case(r8_State)
	stAN_ENABLE 	:r240_ANStateName<="stAN_ENABLE 	";
	stAN_RESTART 	:r240_ANStateName<="stAN_RESTART 	";
	stABILITY_DTECT	:r240_ANStateName<="stABILITY_DTECT	";
	stACK_DTECT		:r240_ANStateName<="stACK_DTECT		";
	stCMPLT_ACK		:r240_ANStateName<="stCMPLT_ACK		";
	stIDLE_DTECT	:r240_ANStateName<="stIDLE_DTECT	";
	stLINK_OK		:r240_ANStateName<="stLINK_OK		";
	stAN_DIS_LINKOK	:r240_ANStateName<="stAN_DIS_LINKOK	";
	endcase
	//synopsys synthesis_on
	
endmodule
